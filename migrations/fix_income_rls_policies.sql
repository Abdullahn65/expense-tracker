-- Fix RLS policies for income table to handle legacy records without user_id

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their income" ON income;
DROP POLICY IF EXISTS "Users can create income" ON income;
DROP POLICY IF EXISTS "Users can update income" ON income;
DROP POLICY IF EXISTS "Users can delete income" ON income;

-- Create new policies that allow viewing/managing own income OR legacy records with NULL user_id

CREATE POLICY "Users can view their income"
  ON income
  FOR SELECT
  USING (user_id = auth.uid() OR user_id IS NULL);

CREATE POLICY "Users can create income"
  ON income
  FOR INSERT
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can update income"
  ON income
  FOR UPDATE
  USING (user_id = auth.uid() OR user_id IS NULL)
  WITH CHECK (user_id = auth.uid() OR user_id IS NULL);

CREATE POLICY "Users can delete income"
  ON income
  FOR DELETE
  USING (user_id = auth.uid() OR user_id IS NULL);
