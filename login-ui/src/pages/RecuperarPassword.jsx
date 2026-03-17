import { useState } from "react"

function RecuperarPassword(){

    const [username,setUsername] = useState("")

    const recuperar = async () => {

        const response = await fetch(
            `http://localhost:8080/usuarios/recuperar-password?username=${username}`,
            { method:"POST" }
        )

        if(response.ok){
            alert("Se envió una contraseña temporal a tu correo")
        }else{
            alert("Usuario no encontrado")
        }

    }

    return(

        <div style={{width:"300px",margin:"100px auto"}}>

            <h2>Recuperar contraseña</h2>

            <input
                type="text"
                placeholder="Usuario"
                value={username}
                onChange={(e)=>setUsername(e.target.value)}
            />

            <br/><br/>

            <button onClick={recuperar}>
                Recuperar contraseña
            </button>

        </div>
    )
}

export default RecuperarPassword