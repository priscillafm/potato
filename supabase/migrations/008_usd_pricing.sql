-- Precios de los planes en dólares (lo que ve el cliente) y una cotización editable
-- para convertirlos a pesos uruguayos al cobrar con Mercado Pago.

ALTER TABLE plans ADD COLUMN IF NOT EXISTS price_monthly_usd numeric(10,2);
ALTER TABLE plans ADD COLUMN IF NOT EXISTS promo_price_monthly_usd numeric(10,2);

UPDATE plans SET price_monthly_usd = 30, promo_price_monthly_usd = 15 WHERE name = 'pro';

-- Ajustes generales de la plataforma. Lectura pública (la cotización no es un secreto);
-- solo el super_admin puede modificarlos.
CREATE TABLE IF NOT EXISTS app_settings (
  key         text PRIMARY KEY,
  value       text NOT NULL,
  updated_at  timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "lectura publica de ajustes" ON app_settings;
CREATE POLICY "lectura publica de ajustes" ON app_settings FOR SELECT USING (true);

DROP POLICY IF EXISTS "super_admin administra ajustes" ON app_settings;
CREATE POLICY "super_admin administra ajustes" ON app_settings
  FOR ALL USING (fn_is_super_admin()) WITH CHECK (fn_is_super_admin());

INSERT INTO app_settings (key, value) VALUES ('usd_uyu_rate', '40')
ON CONFLICT (key) DO NOTHING;

-- Para terminar la promo (sin tocar código):
--   UPDATE plans SET promo_price_monthly_usd = NULL WHERE name = 'pro';
