-- Fix RLS policies for quick_add_templates table to handle legacy records without user_id

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their quick add templates" ON quick_add_templates;
DROP POLICY IF EXISTS "Users can create quick add templates" ON quick_add_templates;
DROP POLICY IF EXISTS "Users can update quick add templates" ON quick_add_templates;
DROP POLICY IF EXISTS "Users can delete quick add templates" ON quick_add_templates;

-- Create new policies that allow viewing/managing own templates OR legacy records with NULL user_id

CREATE POLICY "Users can view their quick add templates"
  ON quick_add_templates
  FOR SELECT
  USING (user_id = auth.uid() OR user_id IS NULL);

CREATE POLICY "Users can create quick add templates"
  ON quick_add_templates
  FOR INSERT
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can update quick add templates"
  ON quick_add_templates
  FOR UPDATE
  USING (user_id = auth.uid() OR user_id IS NULL)
  WITH CHECK (user_id = auth.uid() OR user_id IS NULL);

CREATE POLICY "Users can delete quick add templates"
  ON quick_add_templates
  FOR DELETE
  USING (user_id = auth.uid() OR user_id IS NULL);
