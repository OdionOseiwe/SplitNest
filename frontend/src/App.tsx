import { useState } from 'react'
import Hero from './pages/Hero'
import Features from './pages/Features'
import UserSay from './pages/UserSay'
import HowItWorks from './pages/HowItWorks'
import Footer from './layout/Footer'

function App() {

  return (
    <div className=''>
      <Hero/>
      <Features/>
      <UserSay/>
      <HowItWorks/>
      <Footer/>
    </div>
  )
}

export default App
