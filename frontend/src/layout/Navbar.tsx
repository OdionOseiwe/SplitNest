import React from 'react'
import { HandCoins } from 'lucide-react';

function Navbar() {
  return (
    <nav className='fixed left-0 top-0 right-0 z-50 bg-white border-b border-gray-200 py-4
                    '>
        <div className='flex justify-between max-w-7xl mx-auto px-4'>
            <div className='flex items-center'>
                <p className='text-xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 text-transparent bg-clip-text mr-3'>splitNest</p>
                <HandCoins color='purple'/>
            </div>
            <div className='flex space-x-8 text-gray-700'>
              <p>Home</p>
              <p>About</p>
              <p>How is works</p>
              <p>Features</p>
              <p>Testimonials</p>
            </div>
        </div>
     
    </nav>
  )
}

export default Navbar
