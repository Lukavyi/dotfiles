import { FC, useCallback } from 'react';
import { useState } from 'react';
import { Box, Text, useApp, useInput } from 'ink';
import { categories, defaultSelections } from './config.js';
import CategoryList from './components/CategoryList.js';
import Summary from './components/Summary.js';
import Installer from './components/Installer.js';

type Phase = 'selecting' | 'confirming' | 'installing' | 'complete';

const App: FC = () => {
  const [phase, setPhase] = useState<Phase>('selecting');
  const [selections, setSelections] = useState<string[]>(defaultSelections);
  const [cursor, setCursor] = useState(0);
  const { exit } = useApp();

  const totalItems = Object.values(categories).flat().length;

  useInput((input, key) => {
    if (phase === 'selecting') {
      if (key.upArrow) {
        setCursor((prev) => (prev - 1 + totalItems) % totalItems);
      } else if (key.downArrow) {
        setCursor((prev) => (prev + 1) % totalItems);
      } else if (input === ' ') {
        const allItems = Object.values(categories).flat();
        const currentItem = allItems[cursor];
        setSelections((prev) =>
          prev.includes(currentItem.id)
            ? prev.filter((id) => id !== currentItem.id)
            : [...prev, currentItem.id]
        );
      } else if (input === 'a' || input === 'A') {
        const allItems = Object.values(categories).flat();
        const allItemIds = allItems.map((item) => item.id);

        // If all items are selected, deselect all
        // Otherwise, select all
        if (allItemIds.every((id) => selections.includes(id))) {
          setSelections([]);
        } else {
          setSelections(allItemIds);
        }
      } else if (key.return) {
        setPhase('confirming' as Phase);
      } else if (input === 'q' || key.escape) {
        exit();
      }
    } else if (phase === 'confirming') {
      if (input === 'y' || input === 'Y') {
        // Only proceed if something is selected
        if (selections.length > 0) {
          setPhase('installing' as Phase);
        } else {
          // Skip directly to complete if nothing selected
          setPhase('complete' as Phase);
        }
      } else if (input === 'n' || input === 'N') {
        setPhase('selecting' as Phase);
      } else if (key.escape) {
        exit();
      }
    }
  });

  const setComplete = useCallback(() => setPhase('complete' as Phase), []);

  if (phase === 'selecting') {
    return (
      <Box flexDirection="column">
        <Text color="green" bold>
          🏠 Dotfiles Installation Wizard
        </Text>
        <Text dimColor>
          Use arrow keys to navigate, space to toggle, a to select/deselect all,
          enter to confirm
        </Text>
        <Box marginTop={1}>
          <CategoryList
            categories={categories}
            selections={selections}
            cursor={cursor}
          />
        </Box>
      </Box>
    );
  }

  if (phase === 'confirming') {
    return (
      <Box flexDirection="column">
        <Summary categories={categories} selections={selections} />
        <Box marginTop={1}>
          <Text>Proceed with installation? (y/n)</Text>
        </Box>
      </Box>
    );
  }

  if (phase === 'installing') {
    return (
      <Installer
        categories={categories}
        selections={selections}
        onComplete={setComplete}
      />
    );
  }

  if (phase === 'complete') {
    return (
      <Box flexDirection="column">
        <Text color="green" bold>
          {selections.length > 0
            ? '✓ Installation complete!'
            : 'No components were installed'}
        </Text>
        {selections.length > 0 && (
          <Box marginTop={1} flexDirection="column">
            <Text>Next steps:</Text>
            <Text> 1. Restart your shell or run: source ~/.zshrc</Text>
            <Text> 2. Check missing apps: cd apps && ./check_apps.sh</Text>
          </Box>
        )}
      </Box>
    );
  }

  return null;
};

export default App;
