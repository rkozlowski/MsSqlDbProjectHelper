CREATE TABLE [Flag].[CodeGenOption] (
    [Value]       SMALLINT     NOT NULL,
    [Name]        VARCHAR (50) NOT NULL,
    [IsSingleBit] BIT          CONSTRAINT [DF_CodeGenOption_IsSingleBit] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_CodeGenOption] PRIMARY KEY CLUSTERED ([Value] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CodeGenOption_Name]
    ON [Flag].[CodeGenOption]([Name] ASC);

