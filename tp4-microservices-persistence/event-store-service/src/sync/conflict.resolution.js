class ConflictResolutionService {
  
  // =========================================================================
  // TODO-CONFLICT1: Implémentez la détection de conflits de version
  // =========================================================================
  /**
   * Cette méthode doit détecter les conflits entre versions locales et distantes
   * 
   * Critères de détection :
   * 1. Comparer les numéros de version
   * 2. Comparer les timestamps de modification
   * 3. Identifier le type de conflit :
   *    - CONCURRENT_UPDATE: modifications simultanées
   *    - STALE_UPDATE: mise à jour sur une version obsolète
   *    - VERSION_MISMATCH: incohérence de version
   * 4. Retourner un objet décrivant le conflit
   * 
   * @param {Object} localData - Données locales
   * @param {Object} remoteData - Données distantes
   * @returns {Object} Information sur le conflit détecté
   */
  detectVersionConflict(localData, remoteData) {
    // ⚠️  TODO: À implémenter par les étudiants
    
    // Exemple de solution :
    // if (!localData || !remoteData) {
    //   return { hasConflict: false };
    // }
    // 
    // const conflict = {
    //   hasConflict: false,
    //   type: null,
    //   details: {}
    // };
    // 
    // // Comparer les versions
    // if (localData.version === remoteData.version && 
    //     localData.lastModified !== remoteData.lastModified) {
    //   conflict.hasConflict = true;
    //   conflict.type = 'CONCURRENT_UPDATE';
    //   conflict.details = {
    //     localVersion: localData.version,
    //     remoteVersion: remoteData.version,
    //     localModified: localData.lastModified,
    //     remoteModified: remoteData.lastModified
    //   };
    // } else if (remoteData.version < localData.version) {
    //   conflict.hasConflict = true;
    //   conflict.type = 'STALE_UPDATE';
    //   conflict.details = {
    //     message: 'Remote update is based on older version'
    //   };
    // }
    // 
    // return conflict;
    
    return { hasConflict: false }; // Placeholder - à remplacer
  }

  // =========================================================================
  // TODO-CONFLICT2: Implémentez la stratégie "Last Writer Wins"
  // =========================================================================
  /**
   * Cette stratégie résout les conflits en favorisant la dernière écriture
   * 
   * Logique :
   * 1. Comparer les timestamps de dernière modification
   * 2. Sélectionner les données avec le timestamp le plus récent
   * 3. Préserver certains champs critiques si nécessaire
   * 4. Retourner les données fusionnées
   * 
   * @param {Object} localData - Données locales
   * @param {Object} remoteData - Données distantes
   * @returns {Object} Données résolues selon Last Writer Wins
   */
  resolveConflictLastWriterWins(localData, remoteData) {
    // ⚠️  TODO: À implémenter par les étudiants
    
    // Exemple de solution :
    // if (!localData) return remoteData;
    // if (!remoteData) return localData;
    // 
    // const localTime = new Date(localData.lastModified || 0).getTime();
    // const remoteTime = new Date(remoteData.lastModified || 0).getTime();
    // 
    // // Sélectionner les données les plus récentes
    // const winner = localTime > remoteTime ? localData : remoteData;
    // 
    // // Optionnel : préserver certains champs critiques
    // const resolved = {
    //   ...winner,
    //   _conflictResolution: {
    //     strategy: 'LAST_WRITER_WINS',
    //     resolvedAt: new Date(),
    //     localTimestamp: localTime,
    //     remoteTimestamp: remoteTime,
    //     winner: localTime > remoteTime ? 'local' : 'remote'
    //   }
    // };
    // 
    // return resolved;
    
    return localData; // Placeholder - à remplacer
  }

  // =========================================================================
  // TODO-CONFLICT3: Implémentez la stratégie de merge intelligent
  // =========================================================================
  /**
   * Cette stratégie tente de fusionner les modifications non conflictuelles
   * 
   * Logique :
   * 1. Identifier les champs modifiés dans chaque version
   * 2. Pour les champs modifiés dans une seule version, prendre cette valeur
   * 3. Pour les champs modifiés dans les deux versions :
   *    - Si valeurs identiques, pas de conflit
   *    - Si valeurs différentes, appliquer une règle (ex: max, concat, etc.)
   * 4. Construire l'objet fusionné
   * 5. Marquer les champs en conflit pour revue manuelle si nécessaire
   * 
   * @param {Object} localData - Données locales
   * @param {Object} remoteData - Données distantes
   * @returns {Object} Données fusionnées intelligemment
   */
  resolveConflictIntelligentMerge(localData, remoteData) {
    // ⚠️  TODO: À implémenter par les étudiants
    
    // Exemple de solution :
    // if (!localData) return remoteData;
    // if (!remoteData) return localData;
    // 
    // const merged = {};
    // const conflicts = [];
    // 
    // // Obtenir tous les champs uniques
    // const allFields = new Set([
    //   ...Object.keys(localData),
    //   ...Object.keys(remoteData)
    // ]);
    // 
    // for (const field of allFields) {
    //   const localValue = localData[field];
    //   const remoteValue = remoteData[field];
    //   
    //   if (localValue === remoteValue) {
    //     // Pas de conflit
    //     merged[field] = localValue;
    //   } else if (localValue === undefined) {
    //     // Nouveau champ dans remote
    //     merged[field] = remoteValue;
    //   } else if (remoteValue === undefined) {
    //     // Champ supprimé dans remote
    //     merged[field] = localValue;
    //   } else {
    //     // Conflit réel - appliquer une stratégie
    //     if (field === 'bookedSeats' || field === 'totalRevenue') {
    //       // Pour les compteurs, prendre le maximum
    //       merged[field] = Math.max(localValue, remoteValue);
    //     } else if (field === 'lastModified') {
    //       // Pour les timestamps, prendre le plus récent
    //       merged[field] = new Date(localValue) > new Date(remoteValue) ? localValue : remoteValue;
    //     } else {
    //       // Pour les autres, marquer le conflit
    //       conflicts.push({
    //         field,
    //         localValue,
    //         remoteValue
    //       });
    //       merged[field] = remoteValue; // Favoriser remote par défaut
    //     }
    //   }
    // }
    // 
    // if (conflicts.length > 0) {
    //   merged._conflicts = conflicts;
    // }
    // 
    // merged._conflictResolution = {
    //   strategy: 'INTELLIGENT_MERGE',
    //   resolvedAt: new Date(),
    //   conflictCount: conflicts.length
    // };
    // 
    // return merged;
    
    return localData; // Placeholder - à remplacer
  }

  // Stratégies de résolution disponibles
  getResolutionStrategies() {
    return {
      LAST_WRITER_WINS: this.resolveConflictLastWriterWins.bind(this),
      INTELLIGENT_MERGE: this.resolveConflictIntelligentMerge.bind(this),
      MANUAL_RESOLUTION: this.flagForManualResolution.bind(this)
    };
  }

  flagForManualResolution(localData, remoteData) {
    // Marquer pour résolution manuelle
    return {
      requiresManualResolution: true,
      localData,
      remoteData,
      timestamp: new Date()
    };
  }
}

module.exports = ConflictResolutionService;
