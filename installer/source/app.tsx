import type { FC } from 'react';
import { useState, useCallback, useMemo } from 'react';
import { useApp, useInput } from 'ink';
import { categories, defaultSelections } from './config.js';
import { filterCategoriesByProfile } from './utils/filterByProfile.js';
import { useNavigation } from './hooks/useNavigation.js';
import ItemSelector from './components/ItemSelector.js';
import Confirmation from './components/Confirmation.js';
import CompletionScreen from './components/CompletionScreen.js';
import Installer from './components/Installer.js';

type Phase = 'selecting' | 'confirming' | 'installing' | 'complete';
type Profile = 'work' | 'personal';  // UI shows work/personal, maps to actual profiles

const App: FC = () => {
  const [phase, setPhase] = useState<Phase>('selecting');
  const [profile, setProfile] = useState<Profile>('work');
  const [selections, setSelections] = useState<string[]>(defaultSelections);
  const { exit } = useApp();

  // Filter categories based on profile
  const activeCategories = useMemo(() => {
    return filterCategoriesByProfile(categories, profile);
  }, [profile]);

  // Use navigation hook
  const {
    cursor,
    moveUp,
    moveDown,
    getCurrentItem,
    getCategoryItemIds,
    flatItems,
  } = useNavigation(activeCategories);

  // Handle input
  useInput((input, key) => {
    if (phase === 'selecting') {
      if (key.upArrow) {
        moveUp();
      } else if (key.downArrow) {
        moveDown();
      } else if (key.tab) {
        // Toggle profile between work and personal
        const newProfile = profile === 'work' ? 'personal' : 'work';
        setProfile(newProfile);

        // Clean up selections when switching to work - remove personal-only items
        if (newProfile === 'work') {
          const newCategories = filterCategoriesByProfile(categories, 'work');
          const validIds = Object.values(newCategories).flat().map(item => item.id);
          setSelections(prev => prev.filter(id => validIds.includes(id)));
        }
      } else if (input === ' ') {
        const currentItem = getCurrentItem();
        if (currentItem.isCategory) {
          // Toggle all items in category
          const categoryItemIds = getCategoryItemIds(currentItem.categoryName);
          const allSelected = categoryItemIds.every((id) =>
            selections.includes(id)
          );
          if (allSelected) {
            setSelections((prev) =>
              prev.filter((id) => !categoryItemIds.includes(id))
            );
          } else {
            setSelections((prev) => [
              ...prev.filter((id) => !categoryItemIds.includes(id)),
              ...categoryItemIds,
            ]);
          }
        } else {
          // Toggle single item
          setSelections((prev) =>
            prev.includes(currentItem.id)
              ? prev.filter((id) => id !== currentItem.id)
              : [...prev, currentItem.id]
          );
        }
      } else if (input === 'a' || input === 'A') {
        // Toggle all items globally
        const allItems = Object.values(activeCategories).flat();
        const allItemIds = allItems.map((item) => item.id);
        if (allItemIds.every((id) => selections.includes(id))) {
          setSelections([]);
        } else {
          setSelections(allItemIds);
        }
      } else if (key.return) {
        setPhase('confirming');
      } else if (input === 'q' || key.escape) {
        exit();
      }
    } else if (phase === 'confirming') {
      if (input === 'y' || input === 'Y') {
        if (selections.length > 0) {
          setPhase('installing');
        } else {
          setPhase('complete');
        }
      } else if (input === 'n' || input === 'N') {
        setPhase('selecting');
      } else if (key.escape) {
        exit();
      }
    }
  });

  const handleComplete = useCallback(() => setPhase('complete'), []);

  switch (phase) {
    case 'selecting':
      return (
        <ItemSelector
          categories={activeCategories}
          selections={selections}
          cursor={cursor}
          profile={profile}
          flatItems={flatItems}
        />
      );

    case 'confirming':
      return (
        <Confirmation
          categories={activeCategories}
          selections={selections}
        />
      );

    case 'installing':
      return (
        <Installer
          categories={activeCategories}
          selections={selections}
          profile={profile}
          onComplete={handleComplete}
        />
      );

    case 'complete':
      return <CompletionScreen selections={selections} />;

    default:
      return null;
  }
};

export default App;
