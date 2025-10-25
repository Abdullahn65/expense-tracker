-- One-time data fix for income table: Set user_id for all income entries that don't have one

-- First, temporarily disable RLS to see all records
ALTER TABLE income DISABLE ROW LEVEL SECURITY;

-- Update all income entries without a user_id to the specified user
-- IMPORTANT: Replace 'YOUR_USER_ID' with your actual user ID from the app console
-- UPDATE income SET user_id = 'YOUR_USER_ID' WHERE user_id IS NULL;

-- Re-enable RLS after fixing the data
ALTER TABLE income ENABLE ROW LEVEL SECURITY;

-- Apply the new RLS policies
DROP POLICY IF EXISTS "Users can view their income" ON income;

CREATE POLICY "Users can view their income"
  ON income
  FOR SELECT
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can create income" ON income;

CREATE POLICY "Users can create income"
  ON income
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update income" ON income;

CREATE POLICY "Users can update income"
  ON income
  FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can delete income" ON income;

CREATE POLICY "Users can delete income"
  ON income
  FOR DELETE
  USING (user_id = auth.uid());
