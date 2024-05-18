from fastapi import FastAPI
from routers.producto import router as ruta_Producto

app = FastAPI()
app.include_router(ruta_Producto)

@app.get("/")
def mensaje_inicial():
    return {"mensaje": "Bienvenido a la ApiRest de Ferramas"}
