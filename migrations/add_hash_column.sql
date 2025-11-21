-- Add hash column to expenses table for deduplication
ALTER TABLE expenses ADD COLUMN hash TEXT;

-- Add index on hash for faster lookups
CREATE INDEX idx_expenses_hash ON expenses(hash);

-- Add source column to track if expense is from CSV or manual entry
ALTER TABLE expenses ADD COLUMN source TEXT DEFAULT 'manual';

-- Add index on source for filtering
CREATE INDEX idx_expenses_source ON expenses(source);
