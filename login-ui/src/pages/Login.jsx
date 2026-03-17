import { useState } from "react"

function Login(){

    const [username,setUsername] = useState("")
    const [password,setPassword] = useState("")

    const login = async () => {

        const params = new URLSearchParams()

        params.append("username", username)
        params.append("password", password)

        const response = await fetch("http://localhost:8080/login",{
            method:"POST",
            headers:{
                "Content-Type":"application/x-www-form-urlencoded"
            },
            body: params
        })

        if(response.ok){
            alert("Login correcto")
        }else{

            const mensaje = await response.text()

            alert(mensaje)
        }
    }
    return(

        <div style={{width:"300px",margin:"100px auto"}}>

            <h2>Iniciar sesión</h2>

            <input
                type="text"
                placeholder="Usuario"
                value={username}
                onChange={(e)=>setUsername(e.target.value)}
            />

            <br/><br/>

            <input
                type="password"
                placeholder="Contraseña"
                value={password}
                onChange={(e)=>setPassword(e.target.value)}
            />

            <br/><br/>

            <button onClick={login}>
                Ingresar
            </button>

            <br/><br/>

            <button onClick={()=>window.location="/recuperar"}>
                ¿Olvidaste tu contraseña?
            </button>

        </div>
    )
}

export default Login