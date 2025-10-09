import Hero from './pages/Hero'
import Features from './pages/Features'
import UserSay from './pages/UserSay'
import HowItWorks from './pages/HowItWorks'
import Footer from './layout/Footer'
import Group from './pages/Group'
import {
  PushUniversalWalletProvider,
  PushUI,
} from '@pushchain/ui-kit'
import {
  BrowserRouter,
  Routes,
  Route,
} from 'react-router-dom'

function App() {
  const walletConfig = {
    network: PushUI.CONSTANTS.PUSH_NETWORK.TESTNET,
  }

  return (
    <PushUniversalWalletProvider config={walletConfig}>
      <BrowserRouter>
        <Routes>
          {/* Home Page */}
          <Route
            path="/"
            element={
              <>
                <Hero />
                <Features />
                <UserSay />
                <HowItWorks />
                <Footer />
              </>
            }
          />

          {/* Group Page */}
          <Route path="/group/:id" element={<Group />} />
        </Routes>
      </BrowserRouter>
    </PushUniversalWalletProvider>
  )
}

export default App
