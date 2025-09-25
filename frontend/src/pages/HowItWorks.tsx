import { Wallet,DollarSign, NotebookIcon} from 'lucide-react';


function HowItWorks() {
    const Steps =[
        {
            number:1,
            image:Wallet,
            color: 'bg-blue-100',
            imageColor:'bg-blue-400',
            title:'Connect Your Wallet',
            step:'Log in with your crypto wallet to get started no sign-ups, no banks, just your wallet'
        },
        {
            number:2,
            image:NotebookIcon,
            color: 'bg-green-100',
            imageColor:'bg-green-400',
            title: 'Create or Join a Savings Group',
            step:'Set a goal (like a trip, event, or project) and invite friends, or join an existing group to start contributing '
        },
        {
            number:3,
            image:DollarSign,
            color: 'bg-red-100',
            imageColor:'bg-red-400',
            title: 'Save Together, Unlock Together',
            step:'Deposit securely, track progress transparently on-chain, and when the goal is reached, funds are unlocked for everyone'
        }
    ]
  return (
    <div className=' max-w-7xl m-auto px-4'>
      <div className='text-center md:my-20 my-10 '>
        <h1 className='md:text-4xl  text-3xl font-bold'>How it works</h1>
        <p className='text-gray-700 text-xl mt-3'>How it works in 3 steps</p>
      </div>
        <div className='grid lg:grid-cols-3 md:grid-cols-2 grid-cols-1 gap-8 md:mb-30 mb-10'>
            {
                Steps.map((step)=>(
                    <div className={`${step.color} p-8 rounded-2xl`}>
                        <div className={`${step.imageColor} inline-block p-3 rounded-2xl`}>
                            <step.image color='white' size={30}/>
                        </div>
                        <p className='text-xl text-black font-semibold mt-4'>{step.title}</p>
                        <p className='text-gray-700 mt-4'>{step.step}</p>
                    </div>
                ))
            }
        </div>
    </div>
  )
}

export default HowItWorks
