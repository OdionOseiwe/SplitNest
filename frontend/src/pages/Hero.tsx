import React from 'react'
import Navbar from '../layout/Navbar'
import HeroSection from '../components/HeroSection'

export default function Hero() {
  return (
    <section id='Hero' className='min-h-screen '>
      <Navbar/>
      <HeroSection/>
    </section>
  )
}
