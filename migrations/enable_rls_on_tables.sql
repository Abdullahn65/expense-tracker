-- Enable RLS on expense_templates and recurring_expenses tables
-- Policies already exist, but RLS was never enabled on the tables themselves

ALTER TABLE public.expense_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recurring_expenses ENABLE ROW LEVEL SECURITY;
