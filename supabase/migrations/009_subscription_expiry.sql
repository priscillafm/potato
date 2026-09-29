-- Vencimiento del plan Pro: cada pago aprobado da un mes (current_period_end).
-- Si pasa ese mes más 5 horas de margen sin un pago nuevo, la empresa vuelve a Free.
-- Solo afecta suscripciones pagadas por Mercado Pago (status 'active' con fecha de fin);
-- las empresas que se pusieron en Pro a mano, sin suscripción, no se tocan.

CREATE EXTENSION IF NOT EXISTS pg_cron;

CREATE OR REPLACE FUNCTION fn_expire_subscriptions() RETURNS void AS $$
BEGIN
  WITH expired AS (
    UPDATE company_subscriptions
       SET status = 'past_due', updated_at = now()
     WHERE status = 'active'
       AND current_period_end IS NOT NULL
       AND current_period_end + interval '5 hours' < now()
    RETURNING company_id
  )
  UPDATE companies SET plan = 'free'
   WHERE id IN (SELECT company_id FROM expired);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Corre cada hora, en el minuto 0.
SELECT cron.schedule('expirar-suscripciones', '0 * * * *', 'SELECT fn_expire_subscriptions()');
