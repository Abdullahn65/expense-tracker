-- Create expense_templates table
CREATE TABLE expense_templates (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  vendor TEXT,
  payment_method TEXT NOT NULL,
  is_favorite BOOLEAN DEFAULT false,
  sort_order INTEGER DEFAULT 0,
  times_used INTEGER DEFAULT 0,
  last_used DATE,
  total_spent DECIMAL(12, 2) DEFAULT 0,
  average_amount DECIMAL(10, 2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Create indexes
CREATE INDEX idx_expense_templates_user_id ON expense_templates(user_id);
CREATE INDEX idx_expense_templates_is_favorite ON expense_templates(is_favorite);

-- Enable RLS
ALTER TABLE expense_templates ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own expense templates"
  ON expense_templates FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create expense templates"
  ON expense_templates FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own expense templates"
  ON expense_templates FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own expense templates"
  ON expense_templates FOR DELETE
  USING (auth.uid() = user_id);
