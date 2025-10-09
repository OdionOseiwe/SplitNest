import React from 'react'
import { HandCoins } from 'lucide-react';
import {PushUniversalAccountButton} from '@pushchain/ui-kit';

function Navbar() {
  return (
    <nav className='fixed left-0 top-0 right-0 z-10 bg-white border-b border-gray-200 py-4
                    '>
        <div className='flex justify-between max-w-7xl mx-auto px-4'>
            <div className='flex items-center'>
                <p className='text-xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 text-transparent bg-clip-text mr-3'>splitNest</p>
                <HandCoins color='purple'/>
            </div>
            <div className='flex space-x-8 text-gray-700'>
              <a href='#Hero'>Home</a>
              <a href='#'>About</a>
              <a href='#How-it-works'>How is works</a>
              <a href='#Features'>Features</a>
              <a href='#what-users-say'>Testimonials</a>
            </div>
                  <PushUniversalAccountButton />

        </div>
     
    </nav>
  )
}

export default Navbar
