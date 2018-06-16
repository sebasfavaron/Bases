Orden de ejecucion:
1) en DbVisualizer ejecutar archivo numero 1 (crea las tablas auxiliares y la final)

2) el segundo paso solo se pudo mediante pampero por un problema de permisos:
ejecutamos "psql -h bd1.it.itba.edu.ar -U [nombreUsuario] PROOF -f importacion.sql"
en vez de correr "2 - importacion" desde dbVisualizer. Este paso importa los datos a
la tabla route_imported

3) en DbVisualizer ejecutar archivo numero 3 (crea la funcion que utiliza las tablas 
auxiliares para llegar a completar la tabla route_final)

4) en DbVisualizer ejecutar archivo numero 4 (ejecuta todo lo creado en el paso 3)

5) en DbVisualizer ejecutar archivo numero 5 (crea el trigger que maneja insercion de
tuplas invalidas a la tabla route_final)
