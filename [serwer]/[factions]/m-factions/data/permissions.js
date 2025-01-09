factionPanel_doesHavePermission = (permission) => {
    return factionData.permissions.includes(permission);
}

factionPanel_doesHaveAnyPermission = (permissions) => {
    return permissions.some(permission => factionPanel_doesHavePermission(permission));
}