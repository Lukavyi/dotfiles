import type { Categories } from '../config.js';

/**
 * Filters categories and their items based on the selected profile.
 * - Work profile: Only shows items marked as 'work' or 'all' (or no profile specified)
 * - Personal profile: Shows all items regardless of profile marking
 */
export const filterCategoriesByProfile = (
  categories: Categories,
  profile: 'work' | 'personal'
): Categories => {
  return Object.entries(categories).reduce((filtered, [categoryName, items]) => {
    const profileItems = items.filter((item) => {
      // If no profile is specified, it's available for all
      if (!item.profile) return true;

      // Items marked as 'all' are available for both profiles
      if (item.profile === 'all') return true;

      // Personal profile gets everything
      if (profile === 'personal') return true;

      // Work profile only gets 'work' items
      return item.profile === 'work';
    });

    // Only include category if it has items after filtering
    if (profileItems.length > 0) {
      filtered[categoryName] = profileItems;
    }

    return filtered;
  }, {} as Categories);
};