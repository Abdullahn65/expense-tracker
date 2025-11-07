# Recurring Expenses - User Guide

## ✅ What's New

Your Expense Tracker now has **two major improvements** for managing recurring expenses:

### 1. Edit Recurring Subscriptions 🔧
You can now modify existing recurring subscriptions without having to delete and recreate them.

**How to Edit:**
1. Go to the **Recurring** tab
2. Find the subscription you want to edit
3. Click the **Edit** button
4. Modify any fields you want to change
5. Click **Update Subscription** to save your changes
6. Or click **Cancel** to discard changes

**What You Can Edit:**
- Name/Description
- Category
- Amount
- Frequency (Weekly, Monthly, Quarterly, Yearly, etc.)
- Payment Method
- Notes

### 2. Automatic Transaction Processing ⚡
Recurring expenses are now automatically converted into actual expense entries when they're due.

**How It Works:**
- The app checks for due recurring subscriptions every minute
- When a subscription's due date arrives, it's automatically added to your expenses
- The next due date is automatically calculated based on the frequency
- You'll see a notification when expenses are auto-added
- No manual action needed!

**Example:**
- You create a Netflix subscription (monthly, $15, due on 1st)
- On the 1st of each month, an expense is automatically created
- The next due date is updated to the 1st of the following month
- The system continues this cycle indefinitely

## 🎯 Key Features

| Feature | Before | After |
|---------|--------|-------|
| Edit subscriptions | ❌ Had to delete & recreate | ✅ Edit directly |
| Auto-add expenses | ❌ Had to manually add | ✅ Automatic every minute |
| Flexibility | Limited | Full control |
| Time-saving | Manual work | Automated |

## 📋 Subscription Management

### Adding a Subscription
1. Go to **Recurring** tab
2. Fill in all required fields
3. Click **Add Subscription**

### Editing a Subscription
1. Find the subscription in your list
2. Click **Edit**
3. Modify any fields
4. Click **Update Subscription**

### Removing a Subscription
1. Find the subscription in your list
2. Click **Remove**
3. Confirm deletion

### View Due Status
Each subscription shows its status:
- 🔴 **Due Today** - Subscription is due (or overdue)
- ⚠️ **Due Tomorrow** - Subscription is due in 1 day
- 📅 **In X days** - Subscription will be due in X days

## 🔄 Automatic Processing Schedule

The app automatically checks for due recurring expenses:
- **Frequency**: Every 1 minute
- **Timing**: Starts when you open the app
- **Processing**: All due subscriptions are converted to expenses
- **Notifications**: You'll see a message when expenses are auto-added

## 💡 Tips

1. **Set Correct Due Dates**: The "next due date" is automatically set based on the frequency you choose. Make sure it's correct!

2. **Flexible Frequency Options**:
   - Weekly: Choose a day of the week (Mon, Tue, etc.)
   - Bi-weekly: Every 2 weeks on your chosen day
   - Monthly: Choose a specific day of the month
   - Quarterly: Choose a quarter (Q1, Q2, Q3, Q4)
   - Yearly: Choose a specific day of the year

3. **Check Automatically Generated Expenses**: Since expenses are automatically created, check your expense list to confirm everything looks right.

4. **Edit Before Auto-Adding**: If you need to change an amount or category, edit the recurring subscription BEFORE its due date so the auto-created expense has the correct information.

## ⚙️ Technical Details

- **Check Frequency**: Every 60 seconds
- **Timezone**: Uses your browser's local timezone
- **Storage**: All data is stored in Supabase
- **Console Logging**: Open browser Developer Tools (F12) to see automatic processing logs

## ❓ Frequently Asked Questions

**Q: What if I delete a recurring subscription?**
A: It will no longer appear in your subscriptions list and no more expenses will be auto-added.

**Q: Can I undo an auto-added expense?**
A: Yes, you can manually delete any expense, including auto-added ones.

**Q: What happens if the app is closed?**
A: When you reopen it, it will check for any overdue recurring subscriptions and process them all at once.

**Q: Can I change the auto-check frequency?**
A: Currently it's set to 1 minute. Contact support if you'd like to change this.

**Q: How do I know an expense was auto-added?**
A: The notes field will say "Auto-created from recurring: [subscription name]"

## 🐛 Troubleshooting

**Subscriptions aren't showing up?**
- Make sure they're marked as "active"
- Check that you're logged in
- Try refreshing the page

**Expenses aren't being auto-added?**
- Make sure the due date has arrived
- Wait up to 1 minute for the automatic check
- Check the browser console (F12) for any error messages
- Verify your internet connection is working

**Edit changes aren't saving?**
- Make sure you click "Update Subscription", not "Add Subscription"
- Check that all required fields are filled
- Try refreshing the page if there's an error message

---

**Need help?** Check the browser console (F12 → Console tab) for detailed logs about what's happening with your recurring subscriptions.
