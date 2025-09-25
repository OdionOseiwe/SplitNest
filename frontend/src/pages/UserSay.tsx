import React from 'react'
import {Star, Quote} from 'lucide-react'

function UserSay() {
    const Users =[
        {
            story: 'With this app, my friends and I finally saved enough for our vacation without the stresss of tracking who paid what',
            image: 'https://plus.unsplash.com/premium_photo-1689568126014-06fea9d5d341?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D',
            name: 'Ola John',
            role: 'Trader'
        },
        {
            story: 'It made group saving transparent. I could always see my contributions and progess towards our goal',
            image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRRQA0nWZwLx6fwhMKI_N1nzGOrRU_78S6l326esG8hCEi0M4sjI326cLvw70P659InGq4&usqp=CAU',
            name: 'Marvellous okogele',
            role: 'Student'
        },
        {
            story: 'I no longer worry about someone mishandling our savings since everything is decentralized',
            image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQAT4q66YAil__OT_TK7CVRTYT5krSNKa4yAf2po8HXtNYLJsh5bQsHiV7NqcHqe0ook8o&usqp=CAU',
            name: 'Olalekan Solomon',
            role: 'Founder'
        }
    ]
  return (
    <section id='what-users-say' className='pt-25'>
         <div className=' max-w-7xl m-auto px-4'>
         <div className='text-center md:mb-22 mb-15'>
           <h1 className='md:text-4xl text-3xl font-bold'>What our Users Say</h1>
           <p className='text-gray-700 text-xl mt-3'>Join thousands of Users and families Split bills and save</p>
         </div>
         
           <div className='grid lg:grid-cols-3 md:grid-cols-2 grid-cols-1 gap-8'>
            {
                Users.map((user, index)=>(
                    <div className='bg-gray-50 border-1 border-gray-200 text-gray-700 p-8 rounded-2xl hover:shadow-lg hover:-translate-y-1 hover:bg-gray-200 transition duration-200'>
                        <div className='flex justify-between mb-6'>
                            <p className='flex text-amber-300'>
                                <Star/>
                                <Star/>
                                <Star/>
                                <Star/>
                                <Star/>
                            </p>
                            <Quote color='#92b7f7'/>
                        </div>
                        <p className='mb-6'>"{user.story}"</p>
                        <div className='flex items-center'>
                                <img src={user.image} className=' rounded-full p-1 mr-4 w-16 h-16'/>
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
    </section>
  )
}

export default UserSay
