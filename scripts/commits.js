// const commits = process.env.GIT_COMMITS || '';
const commits = process.argv[2] || '';
console.log('checking args', process.argv);

if (!commits) {
  console.log('No commits');
}

const messages = commits
  .toString()
  .trim()
  .replace(/\+\s/g, '')
  .split(/\n/g)
  .map(message => {
    const [hashTypeScope, ...issueNumberDescription] =
      (/:/.test(message) && message.split(/:/)) || message.split(/\s/);

    const [hash, typeScope = ''] = hashTypeScope.split(/\s/);
    const [issueNumber, ...description] = issueNumberDescription.join(' ').trim().split(/\s/g);

    const updatedTypeScope = (typeScope && `${typeScope}:`) || '';
    const updatedDescription = description.join(' ');
    const [
      updatedMessage,
      remainingMessage = ''
    ] = `${updatedTypeScope} ${issueNumber} ${updatedDescription}`.split(/\(#\d{1,5}\)/);

    return {
      trimmedMessage:
        (remainingMessage.trim().length === 0 && updatedMessage.trim()) ||
        `${updatedTypeScope} ${issueNumber} ${updatedDescription}`,
      hash,
      typeScope: updatedTypeScope,
      issueNumber,
      description: updatedDescription
    };
  });

const messagesList = messages.map(message => {
  const {
    trimmedMessage = null,
    typeScope = null,
    issueNumber = null,
    description = null
  } = message;

  const issueNumberException =
    /(^chore\([\d\D]+\))|(^fix\([\d\D]+\))|(^perf\([\d\D]+\))|(^build\([\d\D]+\))|(^[\d\D]+\(build\))/.test(
      typeScope
    ) || /\(#[\d\D]+\)$/.test(description);

  const typeScopeValid =
    (/(^[\d\D]+\([\d\D]+\):$)|(^[\d\D]+:$)/.test(typeScope) && 'valid') || 'INVALID: type scope';

  const issueNumberValid =
    (/(^issues\/[\d,]+$)/.test(issueNumber) && 'valid') ||
    (issueNumberException && 'valid') ||
    'INVALID: issue number';

  const descriptionValid =
    (/(^[\d\D]+$)/.test(description || (issueNumberException && issueNumber)) && 'valid') ||
    (issueNumberException && !description && issueNumber && 'valid') ||
    'INVALID: description';

  const lengthValid =
    (trimmedMessage && trimmedMessage.length <= 65 && 'valid') ||
    `INVALID: message length (${trimmedMessage && trimmedMessage.length} > 65)`;

  // <type>([scope]): issues/<number> <description> <messageLength>
  return `${typeScope}<${typeScopeValid}> ${issueNumber}<${issueNumberValid}> ${description}<${descriptionValid}><${lengthValid}>`;
});

const filteredMessages = messagesList.filter(
  value => !/<valid>[\d\D]*<valid>[\d\D]*<valid><valid>/.test(value)
);

if (filteredMessages.length) {
  throw new Error(filteredMessages);
} else {
  console.log('Commit lint success');
}
