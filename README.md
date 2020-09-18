# absideon :hankey:
 
[Public release]

Due to xnx 'leaking' the lua. I've decided to create this git to give proper access to everyone.

Note that this wasn't private and was given to anyone who asked.

My guess the reason why xnx released the lua on gs forum was because he got upset when I told him I wouldn't copy paste off nigahook.
Take this release as a cleanup of the garbage that he released.

Features:

1. Dynamic FOV
   - Low (3800 / distanceinfeet * 7 * 0.01)
     - Includes a customizable cap (1-16)
   - Medium (3800 / distance * 25 * 0.01)
   - High (3800 / distance * 55 * 0.01)
   - Maximum (3800 / distance * 85 * 0.01)
   
2. Dynamic autowall
   - On visible
        - Includes a customizable cap (1-10 seconds)
   - Always on
  
3. Indicators
     - Antiaim (displays current bodyyaw)
     - Desync Arrows
        - Small & Large
     - Autowall (displays if the autowall is active)
     - Field of View (displays the current FOV)
     - Force body aim (displays if force body aim is active)
     - Safe point (displays if safe point is active)
     - Fake lag (displays the current fakelag limit)
     
4. Legit anti-aim correction
     - Bruteforce (-60, 60, 0)
     - Opposite (pasted with a little modification)
     
5. Target switch delay
        - Includes a customizable cap (1-1000ms)
        
6. Force autowall (duh)

7. Logs
     - Bruteforce (Displays if the bruteforce failed, and tells the user the new angle)
     - Damage taken (Shows the damage taken)
     
8. Legit AA
     - Manual (60, -60 on key)
     - Freestanding (Forces skeets freestanding bodyyaw)

9. Lowerbody yaw target (obvious tbh)
     - Standing and moving customizablitly
     - Jitter (adds jitter to your bodyyaw)

10. Fake lag flags
     - Default (normal skeet fakelag)
     - On peek
          - On peek time (1-100ms)
          - Override limit on peek (changes from 4 to the sv_maxusrcmdprocessticks on peek)

If I forgot anything, lemme know. :)
