import React from 'react'
import {X} from 'lucide-react'

type propsType ={
  setShowAddMembersModal:(value:Boolean) => void,
}

function AddMembers({setShowAddMembersModal}:propsType) {
  return (
    <div className='flex fixed inset-0 justify-center items-center h-screen z-30 bg-black opacity-90'>
        <div className=' md:w-1/4 m-auto p-4 rounded-lg bg-white'>
            <div className='flex justify-between'>
            <h1 className='font-semibold text-2xl '>Add Members</h1>
            <button className='cursor-pointer' onClick={()=>setShowAddMembersModal(false)}>
              <X/>
            </button>
            </div>
            <div>
              <form>
                <div className='flex flex-col my-5 '>
                  <label>Members address</label>
                  <input type="text" placeholder="Enter members address" className='border-gray-300 border-1 
                  p-2 rounded-md mt-3'  />   
                </div>
                <button className='w-full flex items-center justify-center bg-gradient-to-r from-blue-600 to-purple-600 md:text-xl py-3 md:px-18 space-x-2 px-8 rounded-xl text-white hover:shadow-2xl hover:scale-105 transition duration-300 hover:cursor-pointer'>add members</button>
              </form>
            </div>
        </div>
        
    </div>
  )
}

export default AddMembers
