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
      accent: 'text-blue-600',
      clip:'bg-blue-200'
    },
    {
      icon: CircleCheckBig,
      title: 'Trustless & Secure Transactions',
      description: 'Funds are stored safely on the blockchain, ensuring no single person controls the money. Withdrawals and rules are enforced by smart contracts.',
       color: 'green',
      bgColor: 'bg-green-50 ',
      accent: 'text-green-600 ',
            clip:'bg-green-200'
    },
    {
      icon: Archive,
      title: 'Group Savings Pools',
      description: 'Create shared savings goals with friends, family, or teams. Everyone contributes, and progress is tracked on-chain.',
      color: 'red',
      bgColor: 'bg-red-50',
      accent: 'text-red-600 ',
            clip:'bg-red-200'
    },
    
  ];

  return (
    <section id='Features' className='pt-25 max-w-7xl m-auto px-4'>
      <div className='text-center pb-20 '>
        <h1 className='md:text-4xl  text-3xl font-bold'>Feature Highlights</h1>
        <p className='text-gray-700 text-xl mt-3'>Managing money with friends, family, or teammates doesn’t have to be complicated</p>
      </div>
      
        <div className='grid lg:grid-cols-3 md:grid-cols-2 grid-cols-1 gap-8'>
            {features.map((feature, index)=>(
            <div className= {`${feature.bgColor} relative py-5 px-8 rounded-2xl hover:shadow-2xl hover:-translate-y-1-1 transition duration-300 overflow-hidden`}
                        key={index}>
                <div className={`absolute top-0 right-0  h-24 w-24 ${feature.clip} transform rotate-80 translate-x-8 -translate-y-8`}></div>
                <feature.icon color={feature.color} size={30}/>
                <p className='text-xl font-semibold mt-6'>{feature.title}  </p>
                <p className='text-gray-700 mt-5' >{feature.description}</p>
            </div>
            ))
            }
        </div>
    
      
    </section>
  )
}

export default Features
