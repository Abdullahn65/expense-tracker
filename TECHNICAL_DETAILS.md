# Technical Implementation Details

## Overview
This document provides technical details about the recurring expenses feature implementation.

## Architecture

### Data Flow

```
Database (Supabase)
    ↓
Load recurring_expenses table
    ↓
Local JavaScript array (recurringExpenses)
    ↓
UI Display (renderRecurringList)
    ↓
User Interactions (Edit, Delete, Add)
    ↓
Automatic Scheduler (every 60 seconds)
    ↓
Process Overdue Subscriptions
    ↓
Create Expense Entries
    ↓
Update next_due_date
    ↓
Refresh UI
```

## Core Functions

### 1. `startRecurringExpenseScheduler()`

**Purpose**: Initializes the automatic recurring expense processor

**Location**: Called in `initializeApp()` after data is loaded

**Implementation**:
```javascript
let recurringSchedulerId = null;

function startRecurringExpenseScheduler() {
    // Clear any existing scheduler
    if (recurringSchedulerId) {
        clearInterval(recurringSchedulerId);
    }

    // Check for due recurring expenses every minute
    recurringSchedulerId = setInterval(async () => {
        console.log('🔄 Checking for due recurring expenses...');
        await processOverdueRecurringExpenses();
    }, 60000); // Check every 60 seconds (1 minute)

    console.log('✅ Recurring expense scheduler started');
}
```

**Key Points**:
- Uses `setInterval()` for periodic execution
- Interval: 60,000 milliseconds (1 minute)
- Prevents duplicate schedulers with `clearInterval()`
- Async to handle database operations

### 2. `processOverdueRecurringExpenses()`

**Purpose**: Checks for due recurring expenses and converts them to actual expenses

**Location**: Called on app init and every minute by scheduler

**Flow**:
1. Get current date (00:00:00)
2. Iterate through all active recurring expenses
3. For each one due:
   - Create new expense entry
   - Calculate next due date
   - Update recurring record
4. Refresh UI if any were processed

**Key Logic**:
```javascript
const nextDueDate = new Date(recurring.next_due_date);
nextDueDate.setHours(0, 0, 0, 0);

// If next due date is today or earlier, create the expense
if (nextDueDate <= today) {
    // Create expense
    // Calculate next date
    // Update database
}
```

### 3. `addRecurringExpense()`

**Purpose**: Both adds new and updates existing recurring expenses

**Smart Detection**:
- If `currentEditingRecurringId` is set → UPDATE mode
- If `currentEditingRecurringId` is null → ADD mode

**Add Mode**:
```javascript
const newRecurring = {
    id: Date.now(),
    user_id: user.id,
    ...recurringData,
    created_at: new Date().toISOString()
};

const { error } = await supabaseClient
    .from('recurring_expenses')
    .insert([newRecurring]);
```

**Update Mode**:
```javascript
const { error } = await supabaseClient
    .from('recurring_expenses')
    .update(recurringData)
    .eq('id', currentEditingRecurringId);
```

### 4. `openEditRecurringModal(id)`

**Purpose**: Opens a recurring expense for editing

**Steps**:
1. Find recurring by ID
2. Pre-fill form fields
3. Update frequency-specific fields
4. Change UI to edit mode (button text, colors)
5. Scroll to form

**State Management**:
```javascript
currentEditingRecurringId = id; // Set editing state
```

### 5. `cancelEditRecurring()`

**Purpose**: Cancel editing and reset form

**Steps**:
1. Clear editing state
2. Reset form
3. Update UI back to add mode

### 6. `calculateNextRecurringDate(frequency, dayOfWeek, dayOfMonth, quarter)`

**Purpose**: Calculate the next due date based on frequency settings

**Frequency Logic**:

**Weekly/Bi-weekly**:
```javascript
const targetDay = parseInt(dayOfWeek);
const currentDay = nextDate.getDay();
let daysAhead = targetDay - currentDay;
if (daysAhead <= 0) daysAhead += (frequency === 'weekly' ? 7 : 14);
nextDate.setDate(nextDate.getDate() + daysAhead);
```

**Monthly/Yearly**:
```javascript
const day = parseInt(dayOfMonth) || today.getDate();
// For monthly
nextDate.setMonth(nextDate.getMonth() + 1);
// For yearly
nextDate.setFullYear(nextDate.getFullYear() + 1);
```

**Quarterly**:
```javascript
const quarters = { 'Q1': 0, 'Q2': 3, 'Q3': 6, 'Q4': 9 };
const startMonth = quarters[quarter];
nextDate.setMonth(startMonth);
nextDate.setDate(1);
if (nextDate < today) {
    nextDate.setFullYear(nextDate.getFullYear() + 1);
}
```

## Database Schema

### `recurring_expenses` table structure:
```
Field               | Type      | Purpose
--------------------|-----------|------------------------------------------
id                  | bigint    | Unique identifier
user_id             | uuid      | User who owns the subscription
name                | text      | Subscription name (e.g., "Netflix")
category            | text      | Category (e.g., "Subscriptions")
amount              | numeric   | Amount to charge
frequency           | text      | "weekly", "monthly", "quarterly", "yearly"
day_of_week         | text      | 0-6 for weekly/biweekly (0=Sunday)
day_of_month        | integer   | 1-31 for monthly/yearly
quarter             | text      | "Q1"-"Q4" for quarterly
payment_method      | text      | How payment is made
notes               | text      | Additional notes
active              | boolean   | Is this subscription active?
next_due_date       | date      | When will it next be due?
created_at          | timestamp | When was it created?
```

## UI Components

### Recurring Subscriptions List Item
```html
<div style="background: rgba(255,255,255,0.04); ...">
    <div>Name & Details</div>
    <div>Status (Due Today/Tomorrow/In X days)</div>
    <button onclick="openEditRecurringModal(id)">Edit</button>
    <button onclick="deleteRecurringExpense(id)">Remove</button>
</div>
```

### Form States

**Add State** (Normal):
- Submit button: "Add Subscription"
- Cancel button: hidden
- Form is blank

**Edit State** (When editing):
- Submit button: "Update Subscription" (purple)
- Cancel button: visible
- Form is pre-filled with existing data

## State Management

### Global Variables
```javascript
recurringExpenses = [];          // All active recurring expenses
currentEditingRecurringId = null; // Current editing ID (if any)
recurringSchedulerId = null;      // Scheduler interval ID
```

### State Transitions
```
Normal State
    ↓ (User clicks Edit)
Edit State
    ↓ (User clicks Update or Cancel)
Normal State
```

## Error Handling

### Database Errors
All database operations check for errors:
```javascript
const { error } = await supabaseClient.from('...').insert([...]);
if (error) {
    console.error('❌ Error:', error);
    alert('Error: ' + error.message);
    return;
}
```

### Validation
- Required fields checked before submit
- Frequency-specific fields validated
- User must be logged in

## Logging

### Console Messages
- `🔧 Setting up recurring form...` - Form setup
- `🚀 addRecurringExpense() called` - Submit attempt
- `✅ Successfully inserted/updated` - Success
- `❌ Error:` - Failures
- `🔄 Checking for due recurring expenses...` - Scheduler check
- `✅ Auto-processed X recurring expense(s)` - Automatic creation

## Performance Considerations

### Interval Timing
- 1 minute (60,000 ms) is reasonable for most users
- Can be adjusted in `startRecurringExpenseScheduler()`
- Too frequent: wasted resources
- Too infrequent: delayed processing

### Database Operations
- Only updated records: `next_due_date` and data being edited
- No full table scans
- Efficient filtering with `.eq('active', true)`

### UI Updates
- Only refresh when needed (after changes)
- `renderRecurringList()` called selectively
- No unnecessary re-renders

## Future Enhancements

Possible improvements:
1. **Real-time notifications** - Push notifications when expenses are added
2. **Customizable intervals** - Let users set check frequency
3. **Skip/Postpone** - Skip a recurring expense without deleting
4. **Email reminders** - Alert before due date
5. **Bulk editing** - Edit multiple subscriptions at once
6. **Analytics** - Track spending by subscription
7. **Icalendar export** - Export schedule to calendar apps

## Troubleshooting Guide (Technical)

### Scheduler not running
- Check browser console for error messages
- Verify `startRecurringExpenseScheduler()` was called
- Check that `recurringSchedulerId` is set

### Expenses not auto-adding
- Check database connection
- Verify `next_due_date <= today`
- Check RLS policies on database
- Look for errors in console

### Edit not working
- Verify `currentEditingRecurringId` is set correctly
- Check that form is properly pre-filled
- Verify database update succeeded

### Form not resetting
- Check `cancelEditRecurring()` is called
- Verify `currentEditingRecurringId` is cleared
- Check button states are updated

## Browser Compatibility

- Modern browsers with:
  - ES6+ support
  - `async/await` support
  - `setInterval()` support
  - Modern date handling

Tested on:
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+
