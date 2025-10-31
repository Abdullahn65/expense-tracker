-- Create income_templates table
CREATE TABLE IF NOT EXISTS income_templates (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  source VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, description)
);

-- Enable RLS
ALTER TABLE income_templates ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can see their own income templates"
  ON income_templates FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create income templates"
  ON income_templates FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own income templates"
  ON income_templates FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own income templates"
  ON income_templates FOR DELETE
  USING (auth.uid() = user_id);

-- Index for faster queries
CREATE INDEX idx_income_templates_user_id ON income_templates(user_id);
