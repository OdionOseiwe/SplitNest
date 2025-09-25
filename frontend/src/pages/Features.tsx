import React from 'react'
import { Archive,CircleCheckBig, Shield} from 'lucide-react';

function Features() {
    const features = [
        {
      icon: Shield,
      title: 'Decentralized Fund Splitting',
      description: 'Share expenses transparently without a middleman. Smart contracts handle fair and automatic splitting of funds.',
      color: 'blue',
      bgColor: 'bg-blue-50 ',
      accent: 'text-blue-600'
    },
    {
      icon: CircleCheckBig,
      title: 'Trustless & Secure Transactions',
      description: 'Funds are stored safely on the blockchain, ensuring no single person controls the money. Withdrawals and rules are enforced by smart contracts.',
       color: 'green',
      bgColor: 'bg-green-50 ',
      accent: 'text-green-600 '
    },
    {
      icon: Archive,
      title: 'Group Savings Pools',
      description: 'Create shared savings goals with friends, family, or teams. Everyone contributes, and progress is tracked on-chain.',
      color: 'red',
      bgColor: 'bg-red-50',
      accent: 'text-red-600 '
    },
    
  ];

  return (
    <div className=' max-w-7xl m-auto px-4'>
      <div className='text-center md:my-30 my-15 '>
        <h1 className='md:text-4xl  text-3xl font-bold'>Feature Highlights</h1>
        <p className='text-gray-700 text-xl mt-3'>Managing money with friends, family, or teammates doesn’t have to be complicated</p>
      </div>
      
        <div className='grid lg:grid-cols-3 md:grid-cols-2 grid-cols-1 gap-8 md:mb-30 mb-10'>
            {features.map((feature, index)=>(
            <div className= {`${feature.bgColor} py-5 px-8 rounded-2xl hover:shadow-2xl hover:translate-y-1 transition duration-300 overflow-hidden`}
                        key={index}>
                <feature.icon color={feature.color} size={30}/>
                <p className='text-xl font-semibold mt-6'>{feature.title}  </p>
                <p className='text-gray-700 mt-5' >{feature.description}</p>
            </div>
            ))
            }
        </div>
    
      
    </div>
  )
}

export default Features
