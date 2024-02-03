// see types of prompts:
// https://github.com/enquirer/enquirer/tree/master/examples
//
module.exports = [
  {
    type: 'input',
    name: 'goversion',
    message: "Versión de GO -- Ejemplo (1.15, 1.16, 1.17, 1.18, 1.19, 1.20)"
  },
  {
    type: 'input',
    name: 'pgversion',
    message: "Versión de Postgres"
  },
  {
    type: 'input',
    name: 'dcversion',
    message: "Versión de docker-compose"
  },
  {
    type: 'input',
    name: 'pguser',
    message: "Usuario de la Base de Datos"
  },
  {
    type: 'input',
    name: 'pgpass',
    message: "Contraseña del usuario para la BD"
  },
  {
    type: 'input',
    name: 'pghost',
    message: "Host para la conexión a la BD (127.0.0.1)"
  },
  {
    type: 'input',
    name: 'dbname',
    message: "Nombre de la Base de Datos"
  },
  {
    type: 'input',
    name: 'dbschema',
    message: "Esquema de la Base de Datos"
  }
]