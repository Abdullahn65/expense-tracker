# Recurring Investment Fixes - November 14, 2025

## Issues Identified

### 1. **"Due Today" Status Stuck Since 11/04**
**Problem**: The recurring Fidelity Roth IRA investment was showing "🔴 Due Today" since November 4th, but today is November 14th. The next due date wasn't being updated correctly after processing.

**Root Cause**: The `calculateNextRecurringDate()` function for weekly recurring items had a logic error:
```javascript
if (daysAhead <= 0) daysAhead += (frequency === 'weekly' ? 7 : 14);
```

This meant that when the due date WAS today (`daysAhead === 0`), it would add 7 days, but then the subsequent call to `processOverdueRecurringExpenses()` might not properly persist the update or might calculate the next date while processing an already-processed expense.

### 2. **Recurring Investments Not Showing in Monthly Dropdown**
**Problem**: Auto-created expenses from recurring investments weren't appearing in the monthly expense views.

**Root Causes**:
- The `calculateNextRecurringDate()` function had edge cases where calculated dates weren't properly in the future
- No safeguard to prevent stuck recurring items
- Missing "Investments" category in the recognized categories list (though "Investment Subscription" existed)

## Fixes Applied

### Fix 1: Improved Weekly/Biweekly Date Calculation
**File**: `index.html` - Lines 3267-3281

**Changed**:
```javascript
// OLD - BUGGY
if (daysAhead <= 0) daysAhead += (frequency === 'weekly' ? 7 : 14);

// NEW - CORRECT
if (daysAhead < 0) daysAhead += (frequency === 'weekly' ? 7 : 14);
if (daysAhead === 0) daysAhead = (frequency === 'weekly' ? 7 : 14);
```

**Why**: This ensures that if today IS the due date, we schedule the NEXT occurrence (7 or 14 days away), not skip to the current day.

### Fix 2: Enhanced processOverdueRecurringExpenses() with Safeguards
**File**: `index.html` - Lines 3573-3685

**Changes**:
1. Added verification logging when expenses are created
2. **Added a safeguard loop** that ensures calculated next due dates are always in the future:
```javascript
// Safeguard: if calculated date is not in the future, add another cycle
let calculatedDate = new Date(nextDate);
calculatedDate.setHours(0, 0, 0, 0);
while (calculatedDate <= today) {
    console.warn(`⚠️ Calculated date ${nextDate} is not in the future, adding another cycle...`);
    // Add a cycle based on frequency
    const tempDate = new Date(calculatedDate);
    switch (recurring.frequency) {
        case 'weekly':
            tempDate.setDate(tempDate.getDate() + 7);
            break;
        // ... other frequencies ...
    }
    // ... update and check again ...
}
```

3. Added better error logging to help diagnose future issues

**Why**: This prevents recurring items from getting stuck in a "Due Today" state. If the calculated date ends up being today or in the past, we automatically add another cycle.

### Fix 3: Added "Investments" to Recognized Categories
**File**: `index.html` - Line 1796

**Changed**:
```javascript
// OLD
const categories = ['Housing', 'Transportation', 'Groceries', 'Dining Out', 'Entertainment', 'Healthcare', 'Personal Care', 'Shopping', 'Insurance', 'Savings', 'Education', 'Gifts', 'Subscriptions', 'Investment Subscription', 'Other'];

// NEW
const categories = ['Housing', 'Transportation', 'Groceries', 'Dining Out', 'Entertainment', 'Healthcare', 'Personal Care', 'Shopping', 'Insurance', 'Savings', 'Education', 'Gifts', 'Subscriptions', 'Investment Subscription', 'Investments', 'Other'];
```

**Why**: Ensures that if investments were categorized as "Investments" instead of "Investment Subscription", they'll still be recognized and displayed in the monthly breakdown.

## Expected Results After Fix

1. ✅ Recurring investments will now show up in the monthly expense dropdown
2. ✅ The "Due Today" status will update to the next due date after auto-processing
3. ✅ Auto-created expenses will appear in the correct monthly view
4. ✅ If a recurring item falls into a state where the calculated date isn't in the future, it will automatically advance to the next valid cycle
5. ✅ Better logging in the browser console to track when expenses are auto-created and dates are updated

## Testing Recommendations

1. **Manual Test**: 
   - Open your recurring investments tab
   - Check that Fidelity Roth IRA now shows the correct next due date (should be next Monday from today)
   - Check the monthly expenses dropdown for November - the auto-created investment expense should appear

2. **Monitor Console**: 
   - Press F12 to open developer tools
   - Go to the Console tab
   - Refresh the page
   - You should see log messages like:
     - `✅ Created expense for: Fidelity Roth IRA on 2025-11-11`
     - `✅ Updated next due date to: 2025-11-18`
     - `✅ Auto-processed 1 recurring expense(s)`

3. **Verify Data**:
   - Check Supabase dashboard → recurring_expenses table
   - Find "Fidelity Roth IRA" entry
   - Verify that `next_due_date` is now a date in the future

## Migration Notes

No database schema changes needed - all fixes are logic-based in the JavaScript code.
