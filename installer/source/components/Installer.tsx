import { FC, useMemo } from 'react';
import { useState, useEffect } from 'react';
import { Box, Text } from 'ink';
import Spinner from 'ink-spinner';
import { execa } from 'execa';
import type { Categories } from '../config.js';

interface InstallerProps {
  categories: Categories;
  selections: string[];
  onComplete: () => void;
}

const Installer: FC<InstallerProps> = ({
  categories,
  selections,
  onComplete,
}) => {
  const [currentStep, setCurrentStep] = useState(0);
  const [log, setLog] = useState<string[]>([]);
  const [currentOutput, setCurrentOutput] = useState<string[]>([]);
  const [error, setError] = useState<Error | null>(null);

  const selectedItems = useMemo(
    () =>
      Object.values(categories)
        .flat()
        .filter((item) => selections.includes(item.id)),
    [categories, selections]
  );

  useEffect(() => {
    const runInstallation = async (): Promise<void> => {
      for (let i = 0; i < selectedItems.length; i++) {
        const item = selectedItems[i];
        setCurrentStep(i);
        setLog((prev) => [...prev, `>>> Installing ${item.name}...`]);
        setCurrentOutput([]); // Clear output for new step

        // Collect output in a local variable too
        const stepOutput: string[] = [];

        try {
          // Get the dotfiles directory (parent of installer directory)
          const dotfilesDir = process.cwd().includes('/installer')
            ? process.cwd().replace(/\/installer.*$/, '')
            : process.cwd();

          // Call the script directly
          const subprocess = execa(item.script, [], {
            cwd: dotfilesDir,
            shell: false,
            reject: false,
          });

          // Stream stdout
          if (subprocess.stdout) {
            subprocess.stdout.on('data', (data: Buffer) => {
              const lines = data.toString().split('\n').filter(Boolean);
              stepOutput.push(...lines);
              setCurrentOutput((prev) => [...prev, ...lines]);
            });
          }

          // Stream stderr
          if (subprocess.stderr) {
            subprocess.stderr.on('data', (data: Buffer) => {
              const lines = data.toString().split('\n').filter(Boolean);
              stepOutput.push(...lines);
              setCurrentOutput((prev) => [...prev, ...lines]);
            });
          }

          const result = await subprocess;

          if (result.exitCode === 0) {
            // Add all output to log when step completes
            setLog((prev) => [
              ...prev,
              ...stepOutput,
              `✓ ${item.name} completed successfully`,
            ]);
          } else {
            throw new Error(`Process exited with code ${result.exitCode}`);
          }
        } catch (err) {
          const error = err instanceof Error ? err : new Error(String(err));
          setLog((prev) => [
            ...prev,
            ...stepOutput,
            `✗ ${item.name} failed: ${error.message}`,
          ]);
          setError(error);
        }
      }
      onComplete();
    };

    void runInstallation();
  }, [onComplete, selectedItems]);

  if (error) {
    return (
      <Box flexDirection="column">
        <Text color="red" bold>
          Installation failed:
        </Text>
        <Text color="red">{error.message}</Text>
        <Box marginTop={1} flexDirection="column">
          {log.map((line, i) => (
            <Text key={i}>{line}</Text>
          ))}
        </Box>
      </Box>
    );
  }

  return (
    <Box flexDirection="column">
      <Text color="cyan" bold>
        Installing components...
      </Text>
      <Box marginTop={1}>
        <Text>
          [{currentStep + 1}/{selectedItems.length}]{' '}
          {selectedItems[currentStep]?.name}
        </Text>
        <Box marginLeft={1}>
          <Spinner type="dots" />
        </Box>
      </Box>

      {/* Current command output */}
      {currentOutput.length > 0 && (
        <Box
          marginTop={1}
          flexDirection="column"
          borderStyle="single"
          paddingX={1}
        >
          <Text color="yellow" bold>
            Current Output:
          </Text>
          {currentOutput.slice(-10).map((line, i) => (
            <Text key={`current-${i}`} dimColor>
              {line}
            </Text>
          ))}
        </Box>
      )}

      {/* Full installation log */}
      <Box marginTop={1} flexDirection="column">
        <Text color="green" bold>
          Installation Log:
        </Text>
        {log.slice(-20).map((line, i) => (
          <Text key={`log-${i}`} dimColor>
            {line.startsWith('>>>') ? (
              <Text color="cyan">{line}</Text>
            ) : line.startsWith('✓') ? (
              <Text color="green">{line}</Text>
            ) : line.startsWith('✗') ? (
              <Text color="red">{line}</Text>
            ) : (
              line
            )}
          </Text>
        ))}
      </Box>
    </Box>
  );
};

export default Installer;
