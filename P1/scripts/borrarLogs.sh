#!/bin/bash

# Limpiar logs que tengan más de 7 días de antigüedad
find /ruta/a/logs -type f -mtime +7 -exec rm {} \;
