-- ============================================================
-- ESQUEMA DE BASE DE DATOS — SaDiT
-- Motor: SQLite 3.x
-- ============================================================

CREATE TABLE IF NOT EXISTS sesiones (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT UNIQUE NOT NULL,
    modelo TEXT,
    proyecto TEXT,
    resumen TEXT,
    inicio DATETIME DEFAULT CURRENT_TIMESTAMP,
    fin DATETIME
);

CREATE TABLE IF NOT EXISTS aprendizajes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sesion_id INTEGER REFERENCES sesiones(id),
    categoria TEXT NOT NULL,
    clave TEXT NOT NULL,
    valor TEXT NOT NULL,
    contexto TEXT,
    peso INTEGER DEFAULT 1,
    creado DATETIME DEFAULT CURRENT_TIMESTAMP,
    actualizado DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(categoria, clave)
);

CREATE TABLE IF NOT EXISTS proyectos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT UNIQUE NOT NULL,
    ruta TEXT,
    descripcion TEXT,
    tecnologias TEXT,
    estado TEXT DEFAULT 'activo',
    creado DATETIME DEFAULT CURRENT_TIMESTAMP,
    actualizado DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS logs_conversacion (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sesion_id INTEGER REFERENCES sesiones(id),
    rol TEXT NOT NULL,
    contenido TEXT NOT NULL,
    tokens INTEGER,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS config_sistema (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    fecha DATE DEFAULT (DATE('now')),
    categoria TEXT NOT NULL,
    clave TEXT NOT NULL,
    valor TEXT NOT NULL,
    UNIQUE(fecha, categoria, clave)
);

CREATE TABLE IF NOT EXISTS contexto_activo (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    proyecto TEXT,
    clave TEXT UNIQUE NOT NULL,
    valor TEXT NOT NULL,
    prioridad INTEGER DEFAULT 0,
    expira DATETIME,
    creado DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_aprendizajes_categoria ON aprendizajes(categoria);
CREATE INDEX IF NOT EXISTS idx_aprendizajes_peso ON aprendizajes(peso DESC);
CREATE INDEX IF NOT EXISTS idx_logs_sesion ON logs_conversacion(sesion_id);
CREATE INDEX IF NOT EXISTS idx_contexto_prioridad ON contexto_activo(prioridad DESC);
