import React from 'react'
import { Archive,ReceiptText, Shield, ArrowRight} from 'lucide-react';

function HeroSection() {
  return (
    <div className='md:mt-28 mt-30 '>
      <div className='grid grid-cols-1 md:grid-cols-2 max-w-7xl m-auto px-4'>
        <div>
          <div className='flex bg-blue-100 rounded-full mb-8  text-blue-700 py-2 px-5 w-72'>
            <Archive/>
            <p className=' pl-2'> Save Together, Win Together</p>
          </div>
          <p className='md:text-6xl text-4xl font-bold'>
            <div>Save Together,</div> 
            <div className='bg-gradient-to-r from-blue-600 to-purple-600 text-transparent bg-clip-text p-1'>Win Together</div>
          </p>
          <p className='text-gray-700 md:py-7 py-4 text-xl'>Whether it’s friends, family, or teammates, make money management simple and fun</p>
          <button className='flex items-center bg-gradient-to-r from-blue-600 to-purple-600 md:text-xl py-3 md:px-18 px-6 rounded-xl text-white hover:scale-105 transition duration-300 hover:cursor-pointer'><p className='pr-2'>Get Started </p><ArrowRight /></button>
        </div>
        <div className='bg-gray-300'>
          animations
        </div>
      </div>

      <div className='grid lg:grid-cols-3 md:grid-cols-2 grid-cols-1 gap-5 text-gray-700 my-20 bg-gradient-to-b from-white to-blue-50 py-10 px-24'>
        <div className='text-center'>
          <div className='bg-blue-100 inline-block p-3 rounded-xl'>
            <Shield color='blue' size={40}/>
          </div>
          <p className='font-semibold mt-2'>Chain verified</p>
          <p className=' mt-2'>Automatic network verification prevents costly mistakes</p>
        </div>

        <div className='text-center'>
          <div className='bg-green-100 inline-block p-3 rounded-xl '>
            <ReceiptText color='green' size={40}/>
          </div>
          <p className='font-semibold  mt-2'>Split Bills</p>
          <p className=' mt-2' >Split bills easily with friends and family</p>
        </div>

        <div className='text-center'>
          <div className='bg-red-100 inline-block p-3 rounded-xl'>
            <Archive color='red'size={40}/>
          </div>
          <p className='font-semibold  mt-2'>Team Save</p>
          <p className=' mt-2'>Save for your next adventure</p>
        </div>
      </div>
    </div>
  )
}

export default HeroSection
