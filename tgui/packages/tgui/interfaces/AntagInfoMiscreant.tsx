import { Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

type Info = {
  antag_name: string;
  objectives: Objective[];
  miscreant_squad: string;
};

export const AntagInfoMiscreant = (props) => {
  const { data } = useBackend<Info>();
  const { antag_name, brothers, objectives } = data;
  return (
    <Window width={620} height={650}>
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              You are the {antag_name} squad of {miscreant_squad}!
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout objectives={objectives} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
