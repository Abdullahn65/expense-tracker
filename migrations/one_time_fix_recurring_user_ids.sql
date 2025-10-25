-- One-time data fix: Set user_id for all recurring transactions that don't have one
-- This should be run as a one-time migration before the app loads

-- First, temporarily disable RLS to see all records
ALTER TABLE recurring_transactions DISABLE ROW LEVEL SECURITY;

-- Get all recurring transactions without a user_id and update them
-- For testing/development, we'll set them to a placeholder or first user
-- In production, you'd need to know the actual user_id

-- Option 1: If you know the specific user_id, replace 'YOUR_USER_ID' below:
-- UPDATE recurring_transactions SET user_id = 'YOUR_USER_ID' WHERE user_id IS NULL;

-- Option 2: Set all to a specific user (if you have only one user):
-- First, find your user ID from the auth.users table or from the app console logs
-- Then run: UPDATE recurring_transactions SET user_id = 'YOUR_USER_ID' WHERE user_id IS NULL;

-- Re-enable RLS after fixing the data
ALTER TABLE recurring_transactions ENABLE ROW LEVEL SECURITY;

-- Apply the new RLS policies
DROP POLICY IF EXISTS "Users can view recurring transactions" ON recurring_transactions;

CREATE POLICY "Users can view recurring transactions"
  ON recurring_transactions
  FOR SELECT
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can create recurring transactions" ON recurring_transactions;

CREATE POLICY "Users can create recurring transactions"
  ON recurring_transactions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update recurring transactions" ON recurring_transactions;

CREATE POLICY "Users can update recurring transactions"
  ON recurring_transactions
  FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can delete recurring transactions" ON recurring_transactions;

CREATE POLICY "Users can delete recurring transactions"
  ON recurring_transactions
  FOR DELETE
  USING (user_id = auth.uid());
