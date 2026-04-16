ALTER TABLE IF EXISTS usuarios
    ADD COLUMN IF NOT EXISTS fecha_creacion TIMESTAMP,
    ADD COLUMN IF NOT EXISTS fecha_actualizacion TIMESTAMP,
    ADD COLUMN IF NOT EXISTS creado_por VARCHAR(120),
    ADD COLUMN IF NOT EXISTS actualizado_por VARCHAR(120),
    ADD COLUMN IF NOT EXISTS eliminado BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS fecha_eliminacion TIMESTAMP;

UPDATE usuarios
SET fecha_creacion = COALESCE(fecha_creacion, CURRENT_TIMESTAMP),
    creado_por = COALESCE(creado_por, 'SYSTEM'),
    eliminado = COALESCE(eliminado, FALSE),
    intentos_fallidos = COALESCE(intentos_fallidos, 0),
    activo = COALESCE(activo, TRUE);

ALTER TABLE IF EXISTS usuarios
    ALTER COLUMN fecha_creacion SET DEFAULT CURRENT_TIMESTAMP,
    ALTER COLUMN creado_por SET DEFAULT 'SYSTEM',
    ALTER COLUMN eliminado SET DEFAULT FALSE;

ALTER TABLE IF EXISTS roles
    ADD COLUMN IF NOT EXISTS fecha_creacion TIMESTAMP,
    ADD COLUMN IF NOT EXISTS fecha_actualizacion TIMESTAMP,
    ADD COLUMN IF NOT EXISTS creado_por VARCHAR(120),
    ADD COLUMN IF NOT EXISTS actualizado_por VARCHAR(120),
    ADD COLUMN IF NOT EXISTS eliminado BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS fecha_eliminacion TIMESTAMP;

UPDATE roles
SET fecha_creacion = COALESCE(fecha_creacion, CURRENT_TIMESTAMP),
    creado_por = COALESCE(creado_por, 'SYSTEM'),
    eliminado = COALESCE(eliminado, FALSE);

ALTER TABLE IF EXISTS roles
    ALTER COLUMN fecha_creacion SET DEFAULT CURRENT_TIMESTAMP,
    ALTER COLUMN creado_por SET DEFAULT 'SYSTEM',
    ALTER COLUMN eliminado SET DEFAULT FALSE;
