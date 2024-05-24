from fastapi import APIRouter, HTTPException
from models.producto import Producto

#Vamos a conectar con oracle:
import oracledb
cone = oracledb.connect(user="Ferremas",
                        password="Ferremas",
                        host="127.0.0.1",
                        port=1521,
                        service_name="XE")

router = APIRouter()

@router.get("/Productos")
async def get_Productos():
    try:
        cursor = cone.cursor() #conexión con oracle
        out = cursor.var(int) #variable numérica 0-1
        cursor_productos = cursor.var(oracledb.CURSOR) #variable sys_refcursor: select...
        cursor.callproc("SP_GET_PRODUCTOS", [cursor_productos,out]) #ejecuta el procedimiento
        if out.getvalue() == 1:
            lista = []
            for fila in cursor_productos.getvalue():
                json = {}
                json['codigo'] = fila[0]
                json["imagen"] = fila[1]
                json['nombre_producto'] = fila[2]
                json['descripcion'] = fila[3]
                json['id_marca'] = fila[4]
                json['nombre_marca'] = fila[5]
                json['precio'] = fila[6]
                json['stock'] = fila[7]
                lista.append(json)
            return lista
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()

@router.get("/Productos/{codigo}")
async def get_producto(codigo: str):
    try:
        cursor = cone.cursor() #conexión con oracle
        out = cursor.var(int) #variable numérica 0-1
        cursor_productos = cursor.var(oracledb.CURSOR) #variable sys_refcursor: select...
        cursor.callproc("SP_GET_producto", [codigo,cursor_productos,out]) #ejecuta el procedimiento
        if out.getvalue() == 1:
            json = {}
            for fila in cursor_productos.getvalue():
                json['codigo'] = fila[0]
                json["imagen"] = fila[1]
                json['nombre_producto'] = fila[2]
                json['descripcion'] = fila[3]
                json['id_marca'] = fila[4]
                json['nombre_marca'] = fila[5]
                json['precio'] = fila[6]
                json['stock'] = fila[7]
            return json
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()

@router.post("/Productos")
async def post_producto(producto: Producto):
    try:
        cursor = cone.cursor()
        out = cursor.var(int)
        cursor.callproc("SP_POST_producto", [producto.codigo,
                                            producto.imagen,
                                            producto.nombre_producto,
                                            producto.descripcion,
                                            producto.id_marca,
                                            producto.precio,
                                            producto.stock,
                                            out])
        if out.getvalue()==1:
            cone.commit()
            return producto
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()

@router.put("/Productos/{codigo}")
async def put_producto(codigo:str, producto:Producto):
    try:
        cursor = cone.cursor()
        out = cursor.var(int)
        cursor.callproc("SP_PUT_producto", [producto.codigo,
                                            producto.imagen,
                                            producto.nombre_producto,
                                            producto.descripcion,
                                            producto.id_marca,
                                            producto.precio,
                                            producto.stock,
                                            out])
        if out.getvalue()==1:
            cone.commit()
            return producto
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()

@router.delete("/productos/{codigo}")
async def delete_producto(codigo:str):
    try:
        cursor = cone.cursor()
        out = cursor.var(int)
        cursor.callproc("SP_DELETE_producto", [codigo, out])
        if out.getvalue()==1:
            cone.commit()
            return {"mensaje": "producto eliminado"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()

@router.patch("/productos/{codigo}")
async def path_producto(codigo:str, producto: Producto):
    try:
        cursor = cone.cursor()
        out = cursor.var(int)
        cursor.callproc("SP_PATCH_producto", [producto.codigo,
                                            producto.imagen,
                                            producto.nombre_producto,
                                            producto.descripcion,
                                            producto.id_marca,
                                            producto.precio,
                                            producto.stock,
                                            out])
        if out.getvalue()==1:
            cone.commit()
            return producto
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
