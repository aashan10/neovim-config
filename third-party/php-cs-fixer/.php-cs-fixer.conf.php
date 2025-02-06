<?php

$config = new PhpCsFixer\Config();

$config->setRules([
    '@Symfony' => true,
    'binary_operator_spaces' => [
        'operators' => [
            '=>' => 'align_single_space_minimal_by_scope'
        ]
    ],
]);

return $config;
