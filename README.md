# plantilla_api_crud
Plantilla para la creación de una **API CRUD en GO** con el generador de código automatizado **HYGEN**.

## Prerrequisitos:

1. Instalación de GO y BEEGO.

- [Lineamientos](https://github.com/udistrital/lineamientos_oas/tree/master)

2. Instalar Node v12.

```shell
sudo apt update
```
```shell
sudo apt-get update
```
```shell
sudo apt install npm
```
```shell
sudo npm install -g n
```
```shell
sudo n 12
```

3.	Crear la BD Postgres en local.
4. Instalar e inicializar Hygen en el directorio raiz “~/go/src/github.com/udistrital”.
```shell
cd $GOPATH/src/github.com/udistrital/
```
```shell
sudo npm i -g hygen
```
```shell
hygen init self
```

5.	Instalar Python 2.7 y Python 3.0.
```shell
sudo apt-get update
```
```shell
sudo apt-get install python2.7
```
```shell
sudo apt-get install python3
```

## Creación de API CRUD con Hygen

1.	Ubicarse en el directorio **“~/go/src/github.com/udistrital”**:
```shell
cd $GOPATH/src/github.com/udistrital/
```
2.	Ingresar a la carpeta **_templates**:
```shell
cd _templates
```
3.	Clonar repositorio de plantillas crud:
```shell
git clone https://github.com/udistrital/plantilla_api_crud.git
```
4.	Devolverse a la carpeta raíz:
```shell
cd $GOPATH/src/github.com/udistrital/
```
5.	Ejecutar comando hygen para creación de API CRUD:
```shell
hygen plantilla_api_crud with-prompt --appname nombre_api_crud
```
6.	Ingresar al API recién creado:
```shell
cd nombre_api_crud
```

NOTA: para completar la instrumentación inicial del **API CRUD**, es necesario realizar el migrate del API con los métodos UP y DOWN, la plantilla no genera el migrate completo. Puede encontrar una guía completa en: https://github.com/udistrital/lineamientos_oas/blob/master/generacion_de_apis/beego_migrations.md.

