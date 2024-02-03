---
to: injection.py
force: true
---

import os
import re

# Ruta del directorio que contiene los archivos Go
directorio = '<%= appname %>/models/'

# Texto que deseas inyectar después de "pk"
texto_a_inyectar = ';auto'

# Recorre todos los archivos en el directorio
for archivo in os.listdir(directorio):
    if archivo.endswith('.go'):
        archivo_completo = os.path.join(directorio, archivo)

        # Lee el contenido del archivo
        with open(archivo_completo, 'r') as f:
            contenido = f.read()
        contenido_modificado = contenido
        # Verifica si el archivo contiene "(fk)"
        if "(fk)" in contenido:
            # Realiza la búsqueda y reemplazo
            contenido_modificado = re.sub(r'o\.QueryTable\(new\(Rol\)\)', 'o.QueryTable(new(Rol)).RelatedSel()', contenido)
            # Escribe el contenido modificado en el archivo
            with open(archivo_completo, 'w') as f:
                f.write(contenido_modificado)

        # Realiza la inyección de código
        contenido_modificado = re.sub(r';pk', f';pk{texto_a_inyectar}', contenido_modificado)

        # Escribe el contenido modificado en el archivo
        with open(archivo_completo, 'w') as f:
            f.write(contenido_modificado)