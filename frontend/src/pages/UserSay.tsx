import React from 'react'

function UserSay() {
    const Users =[
        {
            story: 'With this app, my friends and I finally saved enough for our vacation without the stresss of tracking who paid what',
            image: 'image',
            name: 'Ola John',
            role: 'Trader'
        },
        {
            story: 'It made group saving transparent. I could always see my contributions and progess towards our goal',
            image: 'image',
            name: 'Marvellous okogele',
            role: 'Student'
        },
        {
            story: 'I no longer worry about someone mishandling our savings since everything is decentralized',
            image: 'image',
            name: 'Olalekan Solomon',
            role: 'Founder'
        }
    ]
  return (
    <div>
         <div className=' max-w-7xl m-auto px-4'>
         <div className='text-center md:mb-22 mb-15'>
           <h1 className='md:text-4xl text-3xl font-bold'>What our Users Say</h1>
           <p className='text-gray-700 text-xl mt-3'>Join thousands of Users and families Split bills and save</p>
         </div>
         
           <div className='grid lg:grid-cols-3 md:grid-cols-2 grid-cols-1 gap-8 md:mb-30 mb-10'>
            {
                Users.map((user, index)=>(
                    <div className='bg-gray-50 border-1 border-gray-200 text-gray-700 p-8 rounded-2xl'>
                        <div className='flex justify-between mb-6'>
                            <p>*********</p>
                            <p>..</p>
                        </div>
                        <p className='mb-6'>"{user.story}"</p>
                        <div className='flex '>
                            <div className='bg-amber-300 rounded-full p-1 mr-4 '>
                                {user.image}
                            </div>
                            <div>
                                <p className='font-semibold text-black'>{user.name}</p>
                                <p>{user.role}</p>
                            </div>
                        </div>
                    </div>
                ))
            }
             
           </div>
            
         
        </div>
    </div>
  )
}

export default UserSay
