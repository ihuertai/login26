import { BrowserRouter, Routes, Route } from "react-router-dom"
import Login from "./pages/Login"
import RecuperarPassword from "./pages/RecuperarPassword"

function App() {

  return (
      <BrowserRouter>

        <Routes>

          <Route path="/" element={<Login />} />

          <Route path="/recuperar" element={<RecuperarPassword />} />

        </Routes>

      </BrowserRouter>
  )

}

export default App