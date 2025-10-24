-- Add created_at column to recurring_transactions table
ALTER TABLE recurring_transactions
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT now();
