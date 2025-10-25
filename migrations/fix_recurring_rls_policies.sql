-- Fix RLS policies to include legacy records without user_id

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view recurring transactions" ON recurring_transactions;

-- Create new policy that allows viewing own records OR records without user_id (legacy)
CREATE POLICY "Users can view recurring transactions"
  ON recurring_transactions
  FOR SELECT
  USING (auth.uid() = user_id OR user_id IS NULL);

-- Update existing records without user_id to belong to the current user
-- This is a data cleanup that needs to be run after identifying the user
-- For now, we'll let the client handle this via fixRecurringTransactionUserIds()
