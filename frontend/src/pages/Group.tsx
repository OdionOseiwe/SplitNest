import React from 'react'
import {} from 'lucide-react';
import AddMembers from '../Modal/AddmembersModal';

function Group() {
  const [view, setView] = React.useState<'Goals' | 'Bills'>('Goals');
  const [showAddMembersModal, setShowAddMembersModal] = React.useState(false);

  return (
    <div className=' h-screen  '>
      <div className='flex justify-around flex-wrap items-center py-8'>
        <h1 className='text-3xl md:text-xl font-semibold'>Trinity Group</h1>
        <p className='text-blue-500'>Group ID: 123456</p>
        <button onClick={()=>setShowAddMembersModal(true)} className=' flex items-center justify-center px-3 py-2 bg-gradient-to-r from-blue-600 to-purple-600 rounded-xl text-white hover:shadow-2xl hover:scale-105 transition duration-300 hover:cursor-pointer'>Add member</button>
      </div>
      {showAddMembersModal && <AddMembers setShowAddMembersModal={setShowAddMembersModal} />
      }
      <div className='flex flex-col items-center'>
        <h2 className='text-2xl font-semibold pb-5'>Members</h2>
        <ul className='overflow-scroll h-30 w-100   border-1 border-gray-200 rounded-2xl'>
          <li className='bg-gray-300 p-2 m-2 rounded-xl' >Alice</li>
          <li className='bg-gray-300 p-2 m-2 rounded-xl'>Bob</li>
          <li className='bg-gray-300 p-2 m-2 rounded-xl'>Charlie</li>
          
        </ul>
      </div>
      <div className='flex flex-col items-center bg-gray-100 p-4 rounded-lg mt-10'>
        <div className=' space-x-16 my-5 text-lg font-semibold text-blue-800 rounded-2xl'>
          <button className={`${view === 'Goals' ? "bg-blue-200": ""} cursor-pointer rounded-2xl p-4  `} onClick={()=> setView('Goals')}>Goals</button>
          <button  className={`${view === 'Bills' ? "bg-blue-200 ": ""} cursor-pointer rounded-2xl p-4`} onClick={() => setView("Bills")}>Bills</button>
        </div>
        {
          view === "Goals" ? (
          <div >
            <div>
              <h2 className='text-lg font-semibold pb-8'>Goals</h2>
              <div className='overflow-scroll h-30 border-1 border-gray-200 rounded-2xl p-4 '>
                <div className='flex space-x-4 items-center my-4 bg-gray-300 p-3 rounded-xl justify-between'>
                  <p><span className='font-semibold'>Trip to Paris</span> -  Target: <span className='font-semibold'>$3000 </span> - Deadline: <span className='font-semibold'>2023-12-31</span> - My Contribution <span className='font-semibold'>$100</span> </p>
                  <button className=' flex items-center justify-center px-3 py-2 bg-gradient-to-r from-blue-600 to-purple-600 rounded-xl text-white hover:shadow-2xl hover:scale-105 transition duration-300 hover:cursor-pointer'>contribute</button>
                </div>
                <div className='flex space-x-4 items-center my-4 bg-gray-300 p-3 rounded-xl justify-between'>
                  <p><span className='font-semibold'>Trip to Paris</span> -  Target: <span className='font-semibold'>$3000 </span> - Deadline: <span className='font-semibold'>2023-12-31</span>  - My Contribution <span className='font-semibold'>$100</span> </p>
                  <button className=' flex items-center justify-center px-3 py-2 bg-gradient-to-r from-blue-600 to-purple-600 rounded-xl text-white hover:shadow-2xl hover:scale-105 transition duration-300 hover:cursor-pointer'>contribute</button>
                </div>
              </div>
            </div>

          </div>): (
            <div>
              <h2 className='text-lg font-semibold pb-8'>Bills</h2>
              <div className='overflow-scroll h-30 border-1 border-gray-200 rounded-2xl p-4 '>
                <div className='flex space-x-4 items-center my-4 bg-gray-300 p-3 rounded-xl justify-between'>
                  <p><span className='font-semibold'>Electricity Bill</span> -  Total: <span className='font-semibold'>$3000 </span> - My Contribution <span className='font-semibold'>$100</span> </p>
                  <button className=' flex items-center justify-center px-3 py-2 bg-gradient-to-r from-blue-600 to-purple-600 rounded-xl text-white hover:shadow-2xl hover:scale-105 transition duration-300 hover:cursor-pointer'>contribute</button>
                </div>
                <div className='flex space-x-4 items-center my-4 bg-gray-300 p-3 rounded-xl justify-between'>
                  <p><span className='font-semibold'>Electricity Bill</span> -  Total: <span className='font-semibold'>$3000 </span>  - My Contribution <span className='font-semibold'>$100</span> </p>
                  <button className=' flex items-center justify-center px-3 py-2 bg-gradient-to-r from-blue-600 to-purple-600 rounded-xl text-white hover:shadow-2xl hover:scale-105 transition duration-300 hover:cursor-pointer'>contribute</button>
                </div>
              </div>
            </div>
          )
        }
        </div>
    </div>
  )
}

export default Group
