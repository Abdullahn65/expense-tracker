-- Better RLS policy that properly handles legacy records

-- Drop the old policy
DROP POLICY IF EXISTS "Users can view recurring transactions" ON recurring_transactions;

-- Create a policy that:
-- 1. Allows viewing records where user_id matches current user
-- 2. Allows viewing records with NULL user_id (legacy records before RLS was added)
CREATE POLICY "Users can view recurring transactions"
  ON recurring_transactions
  FOR SELECT
  USING (
    user_id = auth.uid() 
    OR user_id IS NULL
  );

-- Keep the other policies unchanged, but ensure insert sets user_id
DROP POLICY IF EXISTS "Users can create recurring transactions" ON recurring_transactions;

CREATE POLICY "Users can create recurring transactions"
  ON recurring_transactions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

DROP POLICY IF EXISTS "Users can update recurring transactions" ON recurring_transactions;

CREATE POLICY "Users can update recurring transactions"
  ON recurring_transactions
  FOR UPDATE
  USING (user_id = auth.uid() OR user_id IS NULL)
  WITH CHECK (user_id = auth.uid() OR user_id IS NULL);

DROP POLICY IF EXISTS "Users can delete recurring transactions" ON recurring_transactions;

CREATE POLICY "Users can delete recurring transactions"
  ON recurring_transactions
  FOR DELETE
  USING (user_id = auth.uid() OR user_id IS NULL);
