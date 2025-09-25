import React from 'react';
import { Send, Smartphone, Laptop, Code, Coffee } from 'lucide-react';


export default function AnimatedHeroSlider() {
  const [currentSlide, setCurrentSlide] = React.useState(0);

  React.useEffect(() => {
    const interval = setInterval(() => {
      setCurrentSlide(prev => (prev + 1) % 2);
    }, 4000); // Change slide every 4 seconds

    return () => clearInterval(interval);
  }, []);


  return (
    <div className="relative w-full h-96 overflow-hidden">
      <div 
        className="flex transition-transform duration-1000 ease-in-out h-full "
        style={{ transform: `translateX(-${currentSlide * 100}%)` }}
      >
        
        <div className="min-w-full relative flex items-center justify-center">
          <div className="relative">
            <img
              src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFMe-U-4xB86j_nzQMDRC5621rNsxc8YZnRw&s"
              alt="Freelancer creating crypto invoice"
              className="w-80 h-96 object-cover rounded-2xl shadow-2xl"
            />
                        
            <div className="absolute top-24 right-16 animate-bounce  duration-1000">
              <div className="w-8 h-8 transform bg-gradient-to-br from-green-500 to-emerald-500 rounded-lg flex items-center justify-center shadow-lg">
                <Smartphone size={14} className="text-white" />
              </div>
            </div>
            
            <div className="absolute top-36 right-12 animate-bounce  duration-1000">
              <div className="w-7 h-7  bg-gradient-to-br from-purple-500 to-pink-500 rounded-full flex items-center justify-center shadow-lg">
                <Code size={12} className="text-white" />
              </div>
            </div>
            
            <div className="absolute bottom-20 left-8 bg-blue-500 text-white px-3 py-1 rounded-full text-xs font-medium animate-pulse">
              <Send size={12} className="inline mr-1" />
              Split bills
            </div>
          </div>
        </div>

        <div className="min-w-full relative flex items-center justify-center">
          <div className="relative">
            <img
              src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQNaR4I9Bj206PDpGj1MLfrI1lTC_qOmx-iOA&s"
              alt="Freelancer creating crypto invoice"
              className="w-80 h-96 object-cover rounded-2xl shadow-2xl"
            />
                        
            <div className="absolute top-24 right-16 animate-bounce  duration-1000">
              <div className="w-8 h-8 bg-gradient-to-br from-green-500 to-emerald-500 rounded-lg flex items-center justify-center shadow-lg">
                <Laptop size={14} className="text-white" />
              </div>
            </div>
            
            <div className="absolute top-36 right-12 animate-bounce  duration-1000">
              <div className="w-7 h-7 bg-gradient-to-br from-purple-500 to-pink-500 rounded-full flex items-center justify-center shadow-lg">
                <Coffee size={12} className="text-white" />
              </div>
            </div>
            
            <div className="absolute bottom-20 left-8 bg-red-500 text-white px-3 py-1 rounded-full text-xs font-medium animate-pulse">
              <Send size={12} className="inline mr-1" />
              save for a trip
            </div>
          </div>
        </div>
      </div>
      
    </div>
  );
}