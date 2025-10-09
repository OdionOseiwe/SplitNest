import  React from 'react'
import { X } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

type Props = {
  setShowCreateGroupModal: (value: boolean) => void;
}

function CreateGroup({setShowCreateGroupModal}:Props) {
  const navigate = useNavigate();


  const Create =(e:React.MouseEvent<HTMLButtonElement>)=>{
    e.preventDefault() // prevent page reload
    setShowCreateGroupModal(false) // Close modal
    navigate('/group/1')
  }

  return (
    <div className='fixed inset-0 bg-black opacity-90 z-20 flex justify-center items-center h-screen'>
        <div className=' md:w-1/4 m-auto p-4 rounded-lg bg-white overflow-y-auto'>
            <div className='flex justify-between items-center mb-4'>
              <h1 className='font-semibold text-2xl'>Create a new group</h1>
              <div onClick={()=>setShowCreateGroupModal(false)} className='cursor-pointer'>
                <X   className=''/>
              </div>
            </div>
            <div>
            <p className='text-gray-500 text-sm'>Create a group to start saving and splitting bills with friends and family</p>
              <form>
                <div className='flex flex-col my-5 '>
                  <label>Group Name</label>
                  <input type="text" placeholder="Enter group name" className='border-gray-300 border-1 
                  focus:border-none p-2 rounded-md mt-3'  />
                </div>
                <button onClick={(e)=> Create(e)} className='w-full flex items-center justify-center bg-gradient-to-r from-blue-600 to-purple-600 md:text-xl py-3 md:px-18 space-x-2 px-8 rounded-xl text-white hover:shadow-2xl hover:scale-105 transition duration-300 hover:cursor-pointer'>create group</button>

              </form>
            </div>
        </div>
        
    </div>
  )
}

export default CreateGroup
