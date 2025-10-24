-- Add missing columns to recurring_transactions table
ALTER TABLE recurring_transactions
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
ADD COLUMN IF NOT EXISTS day_of_week INTEGER,
ADD COLUMN IF NOT EXISTS day_of_month INTEGER,
ADD COLUMN IF NOT EXISTS active BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS next_due_date DATE,
ADD COLUMN IF NOT EXISTS payment_method VARCHAR(255),
ADD COLUMN IF NOT EXISTS user_id UUID DEFAULT auth.uid();

-- Enable RLS on recurring_transactions if not already enabled
ALTER TABLE recurring_transactions ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist to avoid conflicts
DROP POLICY IF EXISTS "Users can view recurring transactions" ON recurring_transactions;
DROP POLICY IF EXISTS "Users can create recurring transactions" ON recurring_transactions;
DROP POLICY IF EXISTS "Users can update recurring transactions" ON recurring_transactions;
DROP POLICY IF EXISTS "Users can delete recurring transactions" ON recurring_transactions;

-- Allow authenticated users to view their own recurring transactions
CREATE POLICY "Users can view recurring transactions"
  ON recurring_transactions
  FOR SELECT
  USING (auth.uid() = user_id);

-- Allow authenticated users to create recurring transactions
CREATE POLICY "Users can create recurring transactions"
  ON recurring_transactions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Allow authenticated users to update their own recurring transactions
CREATE POLICY "Users can update recurring transactions"
  ON recurring_transactions
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Allow authenticated users to delete their own recurring transactions
CREATE POLICY "Users can delete recurring transactions"
  ON recurring_transactions
  FOR DELETE
  USING (auth.uid() = user_id);
