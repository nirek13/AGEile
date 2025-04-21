
# AGEile: Innovative Fall Prevention for Seniors

AGEile Project Gallery
<p align="center">
  <img src="https://github.com/user-attachments/assets/5c6c9631-e5ba-4e9b-8cc1-90ee49c1c493" width="200" />
  <img src="https://github.com/user-attachments/assets/3ebad5bf-a2ce-4b91-bbff-53d" width="200" />
  <img src="https://github.com/user-attachments/assets/d19c0616-efed-46ab-b98d-fa8c94452513" width="200" />
  <img src="https://github.com/user-attachments/assets/76823388-1825-4cb6-b1be-68bc86994771" width="200" />
  <img src="https://github.com/user-attachments/assets/b89a0e70-3826-4a59-af20-5ebc1e379618" width="200" />
  <img src="https://github.com/user-attachments/assets/f7ea7013-eaea-4628-ab64-3eb65f66c416" width="200" />
  <img src="https://github.com/user-attachments/assets/465a4403-96f1-4643-9da2-e82afe7c42ad" width="200" />
  <img src="https://github.com/user-attachments/assets/2d1af374-5ee0-43e7-a1d6-cb7e1ba7d8d2" width="200" />
  <img src="https://github.com/user-attachments/assets/b53e6835-a2c8-45b7-9ea6-eaaf43746780" width="200" />
  <img src="https://github.com/user-attachments/assets/e7a9ee60-6ca5-4e62-afa3-00bb4963d75c" width="200" />
</p>

## Short Description

AGEile is a mobile app that helps seniors stay safe and healthy by identifying fall risks, improving communication with physiotherapists, and simplifying tech with AI automation. Doctors gain valuable patient insights, while seniors enjoy easy, proactive healthcare management for better mobility and safety—all at an affordable price, less than the cost of a meal out.

## Problem Statement

With the elderly population climbing every year, we are faced with a pressing issue: how do we ensure our loved ones receive the care they deserve in a healthcare system that is increasingly burdened, understaffed, and mismanaged?

### The Fall Risk Challenge

Every year in Canada, 350,000 seniors suffer a fall-related injury (Public Health Agency of Canada, 2022). That's not just a number—that's real people, real lives being flipped upside down. To us, a fall might seem trivial—something you brush off and move on from. However, for the elderly, falls pose a distinct danger. Conditions like osteoporosis, which causes bones to become fragile and brittle, make even a minor fall potentially catastrophic. A simple misstep can lead to hip fractures, long-term disability, or death.

- 70% of those who suffer a fall-related injury end up in the emergency department
- Around 7,000 seniors never make it back home each year (Public Health Agency of Canada, 2022)
- Falls cost Canada $2B annually in direct expenses and an additional $10B in indirect costs (Public Health Ontario, 2022)


### The Human Impact

Imagine living in constant fear of falling. You stop going for walks. Stairs become an obstacle. Your life slowly shrinks — not because you want it to, but because you're afraid of one wrong step.

Falls don't just happen—they result from subtle gait irregularities that often go unnoticed by the person experiencing them.

#### A Personal Moment of Inspiration

Almost a year ago, while on vacation with my family, we passed through a poor neighborhood where the sidewalks were made of uneven, worn-down cobblestone. About 50m ahead of us, an elderly man was walking with his family when his foot, slightly dragging, caught on a loose cobblestone, causing him to fall headfirst into the ground. He lay there, unconscious, blood dripping from his forehead, and was quickly rushed to the hospital. I never found out what happened to him, but I do know why it happened: his accident was the real-world result of what happens when gait irregularities are left unnoticed.

## Innovation Details

AGEile is a proactive fall prevention system embedded into footwear, built to monitor real-time mobility patterns and predict fall risks. Embedded sensors continuously monitor gait, posture, and balance, capturing key metrics including step cadence, stride length, weight shifts, and other spatiotemporal data. These sensors preprocess data on-device, using a Kalman filter to reduce noise, before transmitting the refined data via Bluetooth to the phone, which syncs with the cloud-based AI engine.

If an issue arises, AGEile sends instant alerts to users while providing personalized recommendations, like gait adjustments, balance exercises, or medical consultations as well as real-time feedback to prompt users to disrupt bad gait habits.

### Features for Healthcare Providers

Beyond individual monitoring, AGEile features a built-in platform for physiotherapists, allowing them to track patient progress, analyze mobility trends, staying updated with real-time insights. The system's AI is fully integrated into the app, automating essential tasks like scheduling appointments and generating personalized exercise guides. AGEile provides instant data summaries, ensuring healthcare workers have quick, clear insights into their patient's mobility status.

## Research and Design Process

My research process involves an extensive literature review of peer-reviewed studies on fall prediction algorithms, sensor fusion techniques, and AI-driven gait analysis. Key studies, such as "Falls Prevention: Identification of Predictive Fall Risk Factors" (Callis, 2020) and "Comparing Machine Learning Approaches for Fall Risk Assessment" (Silva et al., 2020), helped inform the design of AGEile's predictive models and sensor integration.

Consultations with physiotherapists, caregivers, and professionals in geriatric care played a critical role in refining AGEile's approach. These discussions highlighted the importance of non-invasive, user-friendly technology for seniors, guiding decisions such as simplifying the interface and ensuring that sensor data is actionable for healthcare providers.

## Who Does AGEile Help?

AGEile makes personalized care more accessible and affordable for seniors, offering fall prevention and health monitoring at a fraction of the cost of a personal support worker. For healthcare providers, it reduces workload by automatically diagnosing gait-related conditions and providing data-based insights for fact-checking.

By detecting subtle gait abnormalities that often go unnoticed, AGEile enables early detection of issues like Parkinson's or other problematic gaits, improving health outcomes.

## Differentiating from Existing Solutions

AGEile is different because it focuses on preventing falls rather than just detecting them. Most existing solutions, like fall detection watches (Apple Watches), and medical alert buttons, are reactive only responding after a fall has occurred. Watches can be expensive, and alert buttons require the user to be conscious to press them.

## Implementation Challenges

AGEile's main challenge is senior adoption, a historically less responsive demographic to new technology. Fortunately, while searching for feedback, all 8 physiotherapists I demonstrated AGEile to expressed interest in launching pilot programs once the technology is finalized, helping introduce it into local senior homes.

Smartphone adoption grew by 11% from 2018 to 2021, signaling a growing market. AGEile's automated, user-friendly interface reduces technological barriers, increasing accessibility.
